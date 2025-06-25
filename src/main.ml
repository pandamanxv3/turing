open Types
open Parsing
open Validation
open Execution
open Display
open Printf

let main () =
  printf "Starting ft_turing...\n";
  let usage_msg = "usage: ft_turing [-h] jsonfile input" in
  let args = Array.to_list Sys.argv |> List.tl in
  printf "Arguments: %s\n" (String.concat " " args);
   let (json_file, input) =
    match args with
    | ["-h"] | ["--help"] ->
        printf "%s\n" usage_msg;
        printf "positional arguments:\n";
        printf "  jsonfile    json description of the machine\n";
        printf "  input       input of the machine\n";
        printf "optional arguments:\n";
        printf "  -h, --help  show this help message and exit\n";
        exit 0
    | [jsonfile; input] ->
        if String.length input = 0 then (
          printf "Error: Input cannot be empty. Please provide a valid input string.\n";
          printf "%s\n" usage_msg;
          exit 1
        ) else
          (jsonfile, input)
    | _ ->
        printf "Error: Invalid arguments.\n";
        printf "%s\n" usage_msg;
        exit 1
  in

  try
    printf "Loading machine from %s\n" json_file;
    let machine = parse_machine json_file in
    printf "Machine loaded: %s\n" machine.name;
    printf "Machine states: %d\n" (List.length machine.states);
    validate_machine machine;
    printf "Machine validated, displaying...\n";
    Display.display_machine machine;
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
