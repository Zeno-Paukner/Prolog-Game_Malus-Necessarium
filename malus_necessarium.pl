/* <Malus Necessarium>, by <Lasinger, Lehner, Sarvan, Paukner>. */

:- dynamic i_am_at/1, at/2, holding/1, light_on/1, is_open/1, interaction_mode/1, dialogue_done/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

i_am_at(interrogation_room).
interaction_mode(player).

/* These facts describe how the places are connected.
   hallway name syntax:
   hallway_xy
   x: l lower-level, u upper-level
   y: hallway index, starting top left corner, indexing clockwise, see map for reference
*/

path(interrogation_room, n, hallway_l5).

path(hallway_l5, s, interrogation_room).
path(hallway_l5, w, hallway_l6).
path(hallway_l5, n, hallway_l4).

path(hallway_l6, e, hallway_l5).
path(hallway_l6, s, workshop).

path(hallway_l6, n, electrical_room) :- holding(electrical_room_key) , write('You unlock the door and enter the room.'), nl.
path(hallway_l6, n, electrical_room) :-
        write('The door is appearantly locked.'), nl,
        !, fail.
path(hallway_l6, w, hallway_l7).

path(electrical_room, s, hallway_l6).
path(workshop, n, hallway_l6).

path(hallway_l7, e, hallway_l6).
path(hallway_l7, n, hallway_l1).

path(hallway_l1, w, west_staircase).
path(hallway_l1, s, hallway_l7).
path(hallway_l1, e, hallway_l2).

path(hallway_l2, w, hallway_l1).
path(hallway_l2, e, hallway_l3).
path(hallway_l2, n, jail) :- holding(crowbar) , write('CLACK! The cell door opens slowly.'), nl.
path(hallway_l2, n, jail) :-
        write('The cell door appears locked, but a crowbar might do the trick.'), nl,
        !, fail.

path(jail, s, hallway_l2).

path(hallway_l3, s, party_room).
path(hallway_l3, w, hallway_l2).
path(hallway_l3, e, hallway_l4).

path(party_room, n, hallway_l3).

path(hallway_l4, e, east_staircase) :- holding(dynamite) , write('The blast knocks you back. As the dust settles, you enter the staircase.'), retract(holding(dynamite)), nl.
path(hallway_l4, e, east_staircase) :-
        write('No way getting through this brick wall like that.'), nl,
        !, fail.
path(hallway_l4, w, hallway_l3).
path(hallway_l4, s, hallway_l5).

path(east_staircase, w, hallway_l4).


/* These facts tell where the various objects in the game
   are located. */

at(crowbar, workshop).

/* lights */

light_on(black).

/* color combinations */

equals_green(blue, yellow).
eqauls_green(yellow, blue).
eqauls_purple(blue, red).
eqauls_purple(red, blue).
eqauls_orange(red, yellow).
eqauls_orange(yellow, red).

/* These rules describe how to pick up an object. */

take(X) :-
        holding(X),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(holding(X)),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.

/* These rules describe how to check your inventory */

inventory :- holding(X), write(X).

/* These rules describe how to put down an object. */

drop(X) :-
        holding(X),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.


/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(_) :-
		interaction_mode(player), write('You cannot move while interacting. Finish the interaction first!'), !.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
		nl,
		dialogue(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.                       -- to start the game.'), nl,
        write('n.  s.  e.  w.               -- to go in that direction.'), nl,
        write('take(Object).                -- to pick up an object.'), nl,
        write('drop(Object).                -- to put down an object.'), nl,
        write('investigate(Object)          -- to investigate an object'), nl,
		write('inventory.                   -- to go through your inventory.'), nl,
        write('look.                        -- to look around you again.'), nl,
        write('instructions.                -- to see this message again.'), nl,
        write('connect_wires(Wire1, Wire2). -- to connect 2 wires'), nl,
        write('flip_switch.                 -- to flip a switch'), nl,
        write('halt.                        -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description.

   Possible paths are ordered n, e, s, w
*/

describe(interrogation_room) :- write('You wake up and find yourself tied to a wooden chair with ropes. Your wrists are connected to a lie detector by rusty cables. You can spot bits of the cable where the copper wires are partially exposed. The room you are in looks old and abondened. To the north is a door, which appears to be unlocked. Between you and the door water is dripping down from an old, rusty pipe, forming a puddle of formidable size.'), !, nl.

describe(workshop) :- write('This room looks just as bad as everything else in this building. Broken tools are lying around everywhere. Something possibly resembling a crowbar is lying on the floor.'), !, nl.

describe(west_staircase) :- write('Even though the staircase is in a pretty rough shape, these stairs leading one story up look usable.'), !, nl.

describe(east_staircase) :- write('The explosion destroyed the staircase in a way that climbing these stairs seems impossible.'), !, nl.

describe(east_staircase_upper) :- write('You reach the upper floor, but the stairs to the first floor are destroyed. You can go west to look around the corner.'), !, nl.

describe(electrical_room) :- write('With wires hanging from the ceiling and broken fuzes lying around, this room appears messy and dark. An electrical box to your left catches your attention as it doesn''t look old and shabby like everything else.'), !, nl.

describe(party_room) :- write('A strong smell of booze almost knocks you unconscious. The room is filled with knocked over tables, plastic cups and empty bottles. There might be resources here.'), !, nl.

describe(jail) :- write('Inside the small cell you find two men cowering on the floor with their hands tied to their backs.'), !, nl.


describe(hallway_l1) :- write('You are in hallway L1. To the east is hallway L2. To the south is hallway L7. To the west is an abondened staircase'), !, nl.
describe(hallway_l2) :- write('You are in hallway L2. To the north is a room that appears to serve as a prison. To the east is hallway L3. To the west is hallway L1.'), !, nl.
describe(hallway_l3) :- write('You are in hallway L3. To the east is hallway L4. To the south is a dark room stinking of booze. To the west is  hallway L2.'), !, nl.
describe(hallway_l4) :- write('You are in hallway L4. To the east is a collapsed staircase. To the south is hallway L5. To the west is hallway L3.'), !, nl.
describe(hallway_l5) :- write('You are in hallway L5. To the south is the interrogation room. To the west is hallway L6.'), !, nl.
describe(hallway_l6) :- write('You are in hallway L6. To the north is a door leading to an electrical room. To the east is hallway L5. To the south are double doors leading to a workshop. To the west is hallway L7.'), !, nl.
describe(hallway_l7) :- write('You are in hallway L7. To the north is hallway L1. To the east is hallway L6'), !, nl.


describe(X) :- write('You are at:'), write(X), nl.


/* wire puzzle */

investigate(electrical_box) :- i_am_at(electrical_room), write('You open the electrical box and in it you find wires of every color imaginable. There are also multiple wires of the same color. On top of the box are three turned off lights and a switch. The lights are colored green, orange and purple.').

turn_on_light(Color) :- light_on(Color), !; assert(light_on(Color)).

connect_wires(WireX, WireY) :- equals_green(WireX, WireY), turn_on_light(green), write('The green light turns on.'), !;
                               eqauls_orange(WireX, WireY), turn_on_light(orange), write('The orange light turns on.'), !;
                               eqauls_purple(WireX, WireY), turn_on_light(purple), write('The purple light turns on.'), !.
connect_wires(_, _) :- write('Nothing happens.').

flip_switch :- light_on(green), light_on(orange), light_on(purple), assert(is_open(exit_door)), write('You hear clogs turning.'), nl, !.
flip_switch :- write('Nothing happens.').


/* dialogue */
dialogue(Place) :- dialogue_done(Place), !, nl.
dialogue(Place) :- print_dialogue(Place), assert(dialogue_done(Place)).
print_dialogue(interrogation_room) :- write("Good evening Tiro FE9. Do you have any clue why you are here tonight?").
