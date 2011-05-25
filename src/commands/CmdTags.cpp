////////////////////////////////////////////////////////////////////////////////
// taskwarrior - a command line task list manager.
//
// Copyright 2006 - 2011, Paul Beckingham, Federico Hernandez.
// All rights reserved.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the
//
//     Free Software Foundation, Inc.,
//     51 Franklin Street, Fifth Floor,
//     Boston, MA
//     02110-1301
//     USA
//
////////////////////////////////////////////////////////////////////////////////

#include <sstream>
#include <vector>
#include <stdlib.h>
#include <Context.h>
#include <ViewText.h>
#include <CmdTags.h>
#include <text.h>

extern Context context;

////////////////////////////////////////////////////////////////////////////////
CmdTags::CmdTags ()
{
  _keyword     = "tags";
  _usage       = "task tags";
  _description = "Shows a list of all tags used.";
  _read_only   = true;
  _displays_id = false;
}

////////////////////////////////////////////////////////////////////////////////
int CmdTags::execute (const std::string& command_line, std::string& output)
{
  int rc = 0;
  std::stringstream out;

  std::vector <Task> tasks;
  context.tdb.lock (context.config.getBoolean ("locking"));
  int quantity = 0;
  if (context.config.getBoolean ("list.all.tags"))
    quantity += context.tdb.load (tasks, context.filter);
  else
    quantity += context.tdb.loadPending (tasks, context.filter);

  context.tdb.commit ();
  context.tdb.unlock ();

  // Scan all the tasks for their project name, building a map using project
  // names as keys.
  std::map <std::string, int> unique;
  std::vector <Task>::iterator t;
  for (t = tasks.begin (); t != tasks.end (); ++t)
  {
    std::vector <std::string> tags;
    t->getTags (tags);

    std::vector <std::string>::iterator tag;
    for (tag = tags.begin (); tag != tags.end (); ++tag)
      if (unique.find (*tag) != unique.end ())
        unique[*tag]++;
      else
        unique[*tag] = 1;
  }

  if (unique.size ())
  {
    // Render a list of tags names from the map.
    ViewText view;
    view.width (context.getWidth ());
    view.add (Column::factory ("string", "Tag"));
    view.add (Column::factory ("string.right", "Count"));

    Color bold ("bold");
    bool special = false;
    std::map <std::string, int>::iterator i;
    for (i = unique.begin (); i != unique.end (); ++i)
    {
      // Highlight the special tags.
      special = (context.color () &&
                 (i->first == "nocolor" ||
                  i->first == "nonag"   ||
                  i->first == "next")) ? true : false;

      int row = view.addRow ();
      view.set (row, 0, i->first,  special ? bold : Color ());
      view.set (row, 1, i->second, special ? bold : Color ());
    }

    out << optionalBlankLine ()
        << view.render ()
        << optionalBlankLine ()
        << unique.size ()
        << (unique.size () == 1 ? " tag" : " tags")
        << " (" << quantity << (quantity == 1 ? " task" : " tasks") << ")\n";
  }
  else
  {
    out << "No tags.\n";
    rc = 1;
  }

  output = out.str ();
  return rc;
}

////////////////////////////////////////////////////////////////////////////////