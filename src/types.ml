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
