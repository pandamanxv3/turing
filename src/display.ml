open Types
open Printf

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
