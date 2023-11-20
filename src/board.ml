open Pieces
open Moves

type white_pieces = {
  king : string;
  queen : string;
  rook : string;
  knight : string;
  bishop : string;
  pawn : string;
}

let last_move : last_move ref =
  ref
    {
      last_piece =
        { piece_type = Blank; piece_color = White; piece_pos = (0, 0) };
      last_start_pos = (0, 0);
      last_end_pos = (0, 0);
    }

let white_pieces =
  {
    king = "♔";
    queen = "♕";
    rook = "♖";
    knight = "♘";
    bishop = "♗";
    pawn = "♙";
  }

type black_pieces = {
  king : string;
  queen : string;
  rook : string;
  knight : string;
  bishop : string;
  pawn : string;
}

let black_pieces =
  {
    king = "♚";
    queen = "♛";
    rook = "♜";
    knight = "♞";
    bishop = "♝";
    pawn = "♟︎";
  }

let board =
  [|
    [|
      make_piece Rook Black (0, 0);
      make_piece Knight Black (0, 1);
      make_piece Bishop Black (0, 2);
      make_piece Queen Black (0, 3);
      make_piece King Black (0, 4);
      make_piece Bishop Black (0, 5);
      make_piece Knight Black (0, 6);
      make_piece Rook Black (0, 7);
    |];
    [|
      make_piece Pawn Black (1, 0);
      make_piece Pawn Black (1, 1);
      make_piece Pawn Black (1, 2);
      make_piece Pawn Black (1, 3);
      make_piece Pawn Black (1, 4);
      make_piece Pawn Black (1, 5);
      make_piece Pawn Black (1, 6);
      make_piece Pawn Black (1, 7);
    |];
    [|
      make_piece Blank None (2, 0);
      make_piece Blank None (2, 1);
      make_piece Blank None (2, 2);
      make_piece Blank None (2, 3);
      make_piece Blank None (2, 4);
      make_piece Blank None (2, 5);
      make_piece Blank None (2, 6);
      make_piece Blank None (2, 7);
    |];
    [|
      make_piece Blank None (3, 0);
      make_piece Blank None (3, 1);
      make_piece Blank None (3, 2);
      make_piece Blank None (3, 3);
      make_piece Blank None (3, 4);
      make_piece Blank None (3, 5);
      make_piece Blank None (3, 6);
      make_piece Blank None (3, 7);
    |];
    [|
      make_piece Blank None (4, 0);
      make_piece Blank None (4, 1);
      make_piece Blank None (4, 2);
      make_piece Blank None (4, 3);
      make_piece Blank None (4, 4);
      make_piece Blank None (4, 5);
      make_piece Blank None (4, 6);
      make_piece Blank None (4, 7);
    |];
    [|
      make_piece Blank None (5, 0);
      make_piece Blank None (5, 1);
      make_piece Blank None (5, 2);
      make_piece Blank None (5, 3);
      make_piece Blank None (5, 4);
      make_piece Blank None (5, 5);
      make_piece Blank None (5, 6);
      make_piece Blank None (5, 7);
    |];
    [|
      make_piece Pawn White (6, 0);
      make_piece Pawn White (6, 1);
      make_piece Pawn White (6, 2);
      make_piece Pawn White (6, 3);
      make_piece Pawn White (6, 4);
      make_piece Pawn White (6, 5);
      make_piece Pawn White (6, 6);
      make_piece Pawn White (6, 7);
    |];
    [|
      make_piece Rook White (7, 0);
      make_piece Knight White (7, 1);
      make_piece Bishop White (7, 2);
      make_piece Queen White (7, 3);
      make_piece King White (7, 4);
      make_piece Bishop White (7, 5);
      make_piece Knight White (7, 6);
      make_piece Rook White (7, 7);
    |];
  |]

let print_board board =
  for i = 0 to 7 do
    print_string "\n------------------------------------\n";
    print_string (" " ^ string_of_int (8 - i));
    for j = 0 to 7 do
      print_string " | ";
      match board.(i).(j) with
      | { piece_type = Blank; piece_color = _; piece_pos = _ } ->
          print_string " "
      | { piece_type = p; piece_color = Black; piece_pos = _ } -> (
          match p with
          | Pawn -> print_string black_pieces.pawn
          | Rook -> print_string black_pieces.rook
          | Knight -> print_string black_pieces.knight
          | Bishop -> print_string black_pieces.bishop
          | Queen -> print_string black_pieces.queen
          | King -> print_string black_pieces.king
          | _ -> print_string " |")
      | { piece_type = p; piece_color = White; piece_pos = _ } -> (
          match p with
          | Pawn -> print_string white_pieces.pawn
          | Rook -> print_string white_pieces.rook
          | Knight -> print_string white_pieces.knight
          | Bishop -> print_string white_pieces.bishop
          | Queen -> print_string white_pieces.queen
          | King -> print_string white_pieces.king
          | _ -> print_string " |")
      | _ -> print_string " "
    done;
    print_string " | "
  done;
  print_string
    "\n\
     ------------------------------------\n\
    \   | a | b | c | d | e | f | g | h |\n"

let print_tuple (x, y) =
  print_string "(";
  print_int x;
  print_string ", ";
  print_int y;
  print_string ")"

(* Sets a piece on board curr at position pos. *)
let board_set piece pos curr =
  let z, w = pos in
  let row = curr.(z) in
  let p = set_piece_pos piece pos in
  let _ = row.(w) <- p in
  let _ = curr.(z) <- row in
  curr

(* Helper function to check if move is en_passant move. *)
let is_en_passant_move attacking_pawn last_move end_pos board =
  let start_row, start_col = attacking_pawn.piece_pos in
  let end_row, end_col = end_pos in
  let last_start_row, last_start_col = last_move.last_start_pos in
  let last_end_row, last_end_col = last_move.last_end_pos in

  last_move.last_piece.piece_type = Pawn
  && abs (last_start_row - last_end_row) = 2
  && abs (start_col - end_col) = 1
  && start_row = last_end_row
  && abs (end_row - last_end_row) = 1
  && ((attacking_pawn.piece_color = White && start_row = 3 && end_row = 2)
     || (attacking_pawn.piece_color = Black && start_row = 4 && end_row = 5))
  && board.(last_end_row).(last_end_col).piece_color
     <> attacking_pawn.piece_color

(* Helper function to check if move is a pawn promotion*)
let is_pawn_promotion attacking_pawn end_pos board =
  let is_pawn = attacking_pawn.piece_type = Pawn in
  let end_row, _ = end_pos in
  let color = attacking_pawn.piece_color in
  match color with
  | White when is_pawn -> end_row = 0
  | Black when is_pawn -> end_row = 7
  | _ -> false

(* Helper function to update the board and last move *)
let update_board_and_last_move p start_pos end_pos new_board =
  last_move :=
    { last_piece = p; last_start_pos = start_pos; last_end_pos = end_pos };
  board_set p end_pos new_board

let rec ask_match_choice a =
  print_string "Enter a valid piece type to promote to: ";
  let choice = read_line () in
  let lower = String.lowercase_ascii choice in
  match lower with
  | "knight" -> Knight
  | "queen" -> Queen
  | "bishop" -> Bishop
  | "rook" -> Rook
  | _ -> ask_match_choice ()

(* Precondition: Input must be in chess notation. For example "e4 e5". *)
let make_move (move : string) (curr_game_state : piece array array)
    (turn : color) : piece array array * bool =
  let start_pos = position_of_string (String.sub move 0 2) in
  let end_pos = position_of_string (String.sub move 3 2) in
  let p = piece_at_pos start_pos curr_game_state in

  if
    (within_bounds end_pos && within_bounds start_pos)
    && valid_move curr_game_state p end_pos turn !last_move
  then
    let new_board =
      board_set (make_piece Blank None start_pos) start_pos curr_game_state
    in

    if is_en_passant_move p !last_move end_pos curr_game_state then begin
      print_string "was enpes";
      let end_row, end_col = end_pos in
      let captured_pawn_row =
        if p.piece_color = White then end_row + 1 else end_row - 1
      in
      let captured_pawn = make_piece Blank None (captured_pawn_row, end_col) in
      let new_board_with_captured_pawn =
        board_set captured_pawn (captured_pawn_row, end_col) new_board
      in
      let final_board =
        update_board_and_last_move p start_pos end_pos
          new_board_with_captured_pawn
      in
      (final_board, true)
    end
    else if is_pawn_promotion p end_pos board then begin
      print_string "pawn promotion \n";
      let piece_type = ask_match_choice () in
      let color = p.piece_color in
      let final_board =
        update_board_and_last_move
          (make_piece piece_type color end_pos)
          start_pos end_pos new_board
      in
      (final_board, true)
    end
    else (
      print_string "was valid";
      let final_board =
        update_board_and_last_move p start_pos end_pos new_board
      in
      (final_board, true))
  else begin
    print_endline "illegal move";
    (curr_game_state, false)
  end
