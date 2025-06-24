val parse_action : string -> Types.action
val parse_transition : Yojson.Basic.t -> Types.transition
val parse_state_transitions : string * Yojson.Basic.t -> string * Types.transition list
val parse_machine : string -> Types.machine
