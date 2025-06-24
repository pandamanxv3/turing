open Printf
open Yojson.Basic.Util

(* Types pour la machine de Turing *)
type action = LEFT | RIGHT

type transition = {
  read: string;
  to_state: string;
  write: string;
  action: action;
}

type machine = {
  name: string;
  alphabet: string list;
  blank: string;
  states: string list;
  initial: string;
  finals: string list;
  transitions: (string * transition list) list;
}

type tape = {
  left: string list;
  current: string;
  right: string list;
}

type configuration = {
  state: string;
  tape: tape;
}

(* Fonction pour parser l'action *)
let parse_action = function
  | "LEFT" -> LEFT
  | "RIGHT" -> RIGHT
  | s -> failwith ("Invalid action: " ^ s)

(* Fonction pour parser une transition *)
let parse_transition json =
  {
    read = json |> member "read" |> to_string;
    to_state = json |> member "to_state" |> to_string;
    write = json |> member "write" |> to_string;
    action = json |> member "action" |> to_string |> parse_action;
  }

(* Fonction pour parser les transitions d'un état *)
let parse_state_transitions (state, transitions_json) =
  let transitions = transitions_json |> to_list |> List.map parse_transition in
  (state, transitions)

(* Fonction pour parser la machine depuis JSON *)
let parse_machine json_file =
  let json = Yojson.Basic.from_file json_file in
  let transitions_json = json |> member "transitions" |> to_assoc in
  {
    name = json |> member "name" |> to_string;
    alphabet = json |> member "alphabet" |> to_list |> List.map to_string;
    blank = json |> member "blank" |> to_string;
    states = json |> member "states" |> to_list |> List.map to_string;
    initial = json |> member "initial" |> to_string;
    finals = json |> member "finals" |> to_list |> List.map to_string;
    transitions = List.map parse_state_transitions transitions_json;
  }

(* Validation de la machine *)
let validate_machine machine =
  (* Vérifier que le caractère blank est dans l'alphabet *)
  if not (List.mem machine.blank machine.alphabet) then
    failwith "Blank character must be in alphabet";
  
  (* Vérifier que l'état initial est dans la liste des états *)
  if not (List.mem machine.initial machine.states) then
    failwith "Initial state must be in states list";
  
  (* Vérifier que les états finaux sont dans la liste des états *)
  List.iter (fun final ->
    if not (List.mem final machine.states) then
      failwith ("Final state " ^ final ^ " must be in states list")
  ) machine.finals;
  
  (* Vérifier que tous les caractères de l'alphabet ont une longueur de 1 *)
  List.iter (fun char ->
    if String.length char <> 1 then
      failwith ("Alphabet character '" ^ char ^ "' must have length 1")
  ) machine.alphabet

(* Déterminer les caractères d'entrée valides pour une machine *)
let get_valid_input_chars machine =
  (* Caractères de travail internes à exclure de l'entrée utilisateur *)
  let internal_work_chars = ["X"; "Y"; "x"; "y"; "n"] in
  (* Pour l'entrée utilisateur, on accepte tous les caractères de l'alphabet *)
  (* sauf le blank et les caractères de travail internes *)
  List.filter (fun char -> 
    char <> machine.blank && not (List.mem char internal_work_chars)
  ) machine.alphabet

(* Validation de l'entrée utilisateur *)
let validate_input machine input =
  let valid_chars = get_valid_input_chars machine in
  let input_chars = String.to_seq input |> List.of_seq |> List.map (String.make 1) in
  
  (* Vérifier chaque caractère de l'entrée *)
  List.iter (fun char ->
    if not (List.mem char valid_chars) then (
      printf "Error: Invalid input character '%s'\n" char;
      printf "Valid input characters for machine '%s': [ %s ]\n" 
        machine.name (String.concat ", " valid_chars);
      exit 1
    )
  ) input_chars;
  
  printf "Input validation successful\n"

(* Initialisation du ruban *)
let init_tape input blank =
  match String.to_seq input |> List.of_seq |> List.map (String.make 1) with
  | [] -> { left = []; current = blank; right = [] }
  | h :: t -> { left = []; current = h; right = t }

(* Mouvement vers la gauche *)
let move_left tape blank =
  match tape.left with
  | [] -> { left = []; current = blank; right = tape.current :: tape.right }
  | h :: t -> { left = t; current = h; right = tape.current :: tape.right }

(* Mouvement vers la droite *)
let move_right tape blank =
  match tape.right with
  | [] -> { left = tape.current :: tape.left; current = blank; right = [] }
  | h :: t -> { left = tape.current :: tape.left; current = h; right = t }

(* Écriture sur le ruban *)
let write_tape tape char =
  { tape with current = char }

(* Recherche d'une transition *)
let find_transition machine state char =
  try
    let state_transitions = List.assoc state machine.transitions in
    List.find (fun t -> t.read = char) state_transitions
  with
  | Not_found -> failwith ("No transition found for state " ^ state ^ " and character " ^ char)

(* Affichage du ruban *)
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

(* Affichage de la machine *)
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

(* Simulation de la machine *)
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

(* Fonction principale *)
let main () =
  printf "Starting ft_turing...\n"; 
  let usage_msg = "usage: ft_turing [-h] jsonfile input" in
  
  (* Simple argument parsing without Arg module *)
  let args = Array.to_list Sys.argv in
  let args = List.tl args in (* Remove program name *)
  
  printf "Arguments: %s\n" (String.concat " " args);
  
  let json_file, input = match args with
    | ["-h"] | ["--help"] ->
      printf "%s\n" usage_msg;
      printf "positional arguments:\n";
      printf "  jsonfile    json description of the machine\n";
      printf "  input       input of the machine\n";
      printf "optional arguments:\n";
      printf "  -h, --help  show this help message and exit\n";
      exit 0
    | [jf; inp] -> (jf, inp)
    | _ ->
      printf "%s\n" usage_msg;
      exit 1 in
  
  try
    printf "Loading machine from %s\n" json_file;
    let machine = parse_machine json_file in
    printf "Machine loaded: %s\n" machine.name;
    printf "Machine states: %d\n" (List.length machine.states);
    validate_machine machine;
    printf "Machine validated, displaying...\n";
    display_machine machine;
    
    printf "Validating input: %s\n" input;
    validate_input machine input;
    
    printf "Initializing tape with input: %s\n" input;
    let initial_tape = init_tape input machine.blank in
    let initial_config = { state = machine.initial; tape = initial_tape } in
    
    printf "Starting simulation...\n";
    let _ = simulate machine initial_config 1000 in
    ()
  with
  | Sys_error msg -> printf "Error: %s\n" msg
  | Failure msg -> printf "Error: %s\n" msg
  | Yojson.Json_error msg -> printf "JSON Error: %s\n" msg

let () = main ()