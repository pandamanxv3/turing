open Types
open Printf

let init_tape input blank =
  match String.to_seq input |> List.of_seq |> List.map (String.make 1) with
  | [] -> { left = []; current = blank; right = [] }
  | h :: t -> { left = []; current = h; right = t }

let move_left tape blank =
  match tape.left with
  | [] -> { left = []; current = blank; right = tape.current :: tape.right }
  | h :: t -> { left = t; current = h; right = tape.current :: tape.right }

let move_right tape blank =
  match tape.right with
  | [] -> { left = tape.current :: tape.left; current = blank; right = [] }
  | h :: t -> { left = tape.current :: tape.left; current = h; right = t }

let write_tape tape char =
  { tape with current = char }

let find_transition machine state char =
  try
    let state_transitions = List.assoc state machine.transitions in
    List.find (fun t -> t.read = char) state_transitions
  with
  | Not_found -> failwith ("No transition found for state " ^ state ^ " and character " ^ char)

let display_tape tape =
  let left_str = String.concat "" (List.rev tape.left) in
  let right_str = String.concat "" tape.right in
  let head_pos = String.length left_str in
  let full_tape = left_str ^ tape.current ^ right_str in
  let padded_tape = full_tape ^ String.make (max 0 (15 - String.length full_tape)) '.' in
  "[" ^ String.concat "" (List.init (String.length padded_tape) (fun i ->
    if i = head_pos then "<" ^ String.make 1 padded_tape.[i] ^ ">"
    else String.make 1 padded_tape.[i]
  )) ^ "]"

let display_machine machine =
  printf "********************************************************************************\n";
  printf "*%76s*\n" "";
  printf "*%30s%16s%30s*\n" "" machine.name "";
  printf "*%76s*\n" "";
  printf "********************************************************************************\n";
  printf "Alphabet: [ %s ]\n" (String.concat ", " machine.alphabet);
  printf "States : [ %s ]\n" (String.concat ", " machine.states);
  printf "Initial : %s\n" machine.initial;
  printf "Finals : [ %s ]\n" (String.concat ", " machine.finals);
  List.iter (fun (state, transitions) ->
    List.iter (fun t ->
      printf "(%s, %s) -> (%s, %s, %s)\n" 
        state t.read t.to_state t.write 
        (match t.action with LEFT -> "LEFT" | RIGHT -> "RIGHT")
    ) transitions
  ) machine.transitions;
  printf "********************************************************************************\n"

let rec simulate machine config step_limit =
  if step_limit <= 0 then (
    printf "Maximum steps reached, halting simulation\n";
    config
  ) else if List.mem config.state machine.finals then (
    printf "Machine halted in final state: %s\n" config.state;
    config
  ) else (
    try
      let transition = find_transition machine config.state config.tape.current in
      let new_tape = write_tape config.tape transition.write in
      let moved_tape = match transition.action with
        | LEFT -> move_left new_tape machine.blank
        | RIGHT -> move_right new_tape machine.blank
      in
      let new_config = { state = transition.to_state; tape = moved_tape } in
      printf "%s (%s, %s) -> (%s, %s, %s)\n"
        (display_tape config.tape)
        config.state
        config.tape.current
        transition.to_state
        transition.write
        (match transition.action with LEFT -> "LEFT" | RIGHT -> "RIGHT");
      simulate machine new_config (step_limit - 1)
    with
    | Failure msg -> 
      printf "Machine blocked: %s\n" msg;
      config
  )
