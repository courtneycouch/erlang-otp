/* ``The contents of this file are subject to the Erlang Public License,
 * Version 1.1, (the "License"); you may not use this file except in
 * compliance with the License. You should have received a copy of the
 * Erlang Public License along with this software. If not, it can be
 * retrieved via the world wide web at http://www.erlang.org/.
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
 * the License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Initial Developer of the Original Code is Ericsson Utvecklings AB.
 * Portions created by Ericsson are Copyright 1999, Ericsson Utvecklings
 * AB. All Rights Reserved.''
 * 
 *     $Id$
 */

#ifndef ERL_INSTRUMENT_H__
#define ERL_INSTRUMENT_H__

#define ERTS_INSTR_VSN 2

extern int erts_instr_memory_map;
extern int erts_instr_stat;
#define ERTS_INSTR_SET_CURR_PROC(PID) \
do { if (erts_instr_memory_map) erts_instr_set_curr_proc((PID)); } while (0)
#define ERTS_INSTR_RESET_CURR_PROC() \
do { if (erts_instr_memory_map) erts_instr_reset_curr_proc(); } while (0)

Uint  erts_instr_init(int stat, int map_stat);
void  erts_instr_set_curr_proc(Eterm pid);
void  erts_instr_reset_curr_proc(void);
int   erts_instr_dump_memory_map_to_fd(int fd);
int   erts_instr_dump_memory_map(const char *name);
Eterm erts_instr_get_memory_map(Process *process);
int   erts_instr_dump_stat_to_fd(int fd, int begin_max_period);
int   erts_instr_dump_stat(const char *name, int begin_max_period);
Eterm erts_instr_get_stat(Process *proc, Eterm what, int begin_max_period);
Eterm erts_instr_get_type_info(Process *proc);
Uint  erts_instr_get_total(void);
Uint  erts_instr_get_max_total(void);

#endif