open Types
open Yojson.Basic.Util

let parse_action = function
  | "LEFT" -> LEFT
  | "RIGHT" -> RIGHT
  | s -> failwith ("Invalid action: " ^ s)

let parse_transition json =
  {
    read = json |> member "read" |> to_string;
    to_state = json |> member "to_state" |> to_string;
    write = json |> member "write" |> to_string;
    action = json |> member "action" |> to_string |> parse_action;
  }

let parse_state_transitions (state, transitions_json) =
  let transitions = transitions_json |> to_list |> List.map parse_transition in
  (state, transitions)

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
