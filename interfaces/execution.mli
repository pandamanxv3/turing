val init_tape : string -> string -> Types.tape
val move_left : Types.tape -> string -> Types.tape
val move_right : Types.tape -> string -> Types.tape
val write_tape : Types.tape -> string -> Types.tape
val find_transition : Types.machine -> string -> string -> Types.transition
val display_tape : Types.tape -> string
val display_machine : Types.machine -> unit
val simulate : Types.machine -> Types.configuration -> int -> Types.configuration
