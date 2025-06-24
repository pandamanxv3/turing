open Types
open Printf

let validate_machine machine =
  if not (List.mem machine.blank machine.alphabet) then
    failwith "Blank character must be in alphabet";
  if not (List.mem machine.initial machine.states) then
    failwith "Initial state must be in states list";
  List.iter (fun final ->
    if not (List.mem final machine.states) then
      failwith ("Final state " ^ final ^ " must be in states list")
  ) machine.finals;
  List.iter (fun char ->
    if String.length char <> 1 then
      failwith ("Alphabet character '" ^ char ^ "' must have length 1")
  ) machine.alphabet

let get_valid_input_chars machine =
  let internal_work_chars = ["X"; "Y"; "x"; "y"; "n"] in
  List.filter (fun char -> 
    char <> machine.blank && not (List.mem char internal_work_chars)
  ) machine.alphabet

let validate_input machine input =
  let valid_chars = get_valid_input_chars machine in
  let input_chars = String.to_seq input |> List.of_seq |> List.map (String.make 1) in
  List.iter (fun char ->
    if not (List.mem char valid_chars) then (
      printf "Error: Invalid input character '%s'\n" char;
      printf "Valid input characters for machine '%s': [ %s ]\n" 
        machine.name (String.concat ", " valid_chars);
      exit 1
    )
  ) input_chars;
  printf "Input validation successful\n"
