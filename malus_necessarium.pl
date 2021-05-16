/* <Malus Necessarium>, by <Lasinger, Lehner, Sarvan, Paukner>. */

:- dynamic i_am_at/1, at/2, holding/1, light_on/1, is_open/1, interaction_mode/1, dialogue_done/1, dialogue_stage/1, colleague_rescued/0, colleague_killed/0.
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

path(hallway_l6, n, electrical_room) :- holding(key) , write('You unlock the door and enter the room.'), nl, end.
path(hallway_l6, n, electrical_room) :-
        write('The door is appearantly locked.'), nl,
        !, fail.
path(hallway_l6, w, hallway_l7).

path(electrical_room, s, hallway_l6).
path(workshop, n, hallway_l6).

path(hallway_l7, e, hallway_l6).
path(hallway_l7, n, hallway_l1).

path(hallway_l1, w, lower_exit) :-  is_open(lower_exit), write('You open the door and finally step into freedom...'), nl.
path(hallway_l1, w, lower_exit) :-
        write('The door is locked, which should be illegal due to the it being marked as an emergency exit.'), nl,
        !, fail.
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

path(hallway_l4, e, east_staircase_lower).
path(hallway_l4, w, hallway_l3).
path(hallway_l4, s, hallway_l5).

path(east_staircase_lower, w, hallway_l4).

path(east_staircase_lower, u, east_staircase_upper).
path(east_staircase_upper, d, east_staircase_lower).

path(east_staircase_upper, w, hallway_u1).

path(hallway_u1, e, east_staircase_upper).
path(hallway_u1, s, hallway_u2).

path(hallway_u2, n, hallway_u1).
path(hallway_u2, s, hallway_u3).
path(hallway_u2, w, hallway_u4).

path(hallway_u3, n, hallway_u2).
path(hallway_u3, e, janitor_room).
path(hallway_u3, s, upper_exit).
path(janitor_room, w, hallway_u3).

path(hallway_u4, e, hallway_u2).
path(hallway_u4, s, living_room).
path(hallway_u4, n, operation_room).
path(hallway_u4, w, hallway_u5).
path(operation_room, s, hallway_u4).
path(living_room, n, hallway_u4).

path(hallway_u5, e, hallway_u4).
path(hallway_u5, s, office_room).
path(hallway_u5, w, hallway_u6).
path(office_room, n, hallway_u5).

path(hallway_u6, e, hallway_u5).

/* These facts tell where the various objects in the game
   are located. */

at(crowbar, workshop).
at(spray_can, workshop).
at(key, janitor_room).
at(gun, living_room).
at(computer, operation_room).
at(desk_documents, operation_room).
at(shelf_documents, operation_room).

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

/* This rule describes how to check your inventory */

inventory :- holding(X), write(X).

/* These rules describe objects worth investigating */

investigate(electrical_box) :- i_am_at(electrical_room), write('You open the electrical box and in it you find wires of every color imaginable. There are also multiple wires of the same color. On top of the box are three turned off lights and a switch. The lights are colored green, orange and purple.'), !, nl.
investigate(documents) :- i_am_at(office_room), write('You find a page that only says Password: Turing'), !, nl.
investigate(computer) :- i_am_at(operation_room), write('I need to enter a password in order to access it.'), !, nl.
investigate(desk) :- i_am_at(operation_room), write('In one of the drawers you find pictures of other politicians and powerful people. Are these the next targets? You should probably take these desk documents with you.'), !, nl.
investigate(shelf) :- i_am_at(operation_room), write('Files about the dead US-Vice-President Thomas King and the dead President Mohammed Abiba? Their deaths were declared accidents. Looks like these bastards are behind it. You should probably take these shelf documents with you.'), !, nl.
investigate(cupboard) :- i_am_at(party_room), write('You find a bottle of alcohol, an old piece of clothing and a lighter. What a coincidence! Your natural instincts have just made a molotov out of it! You also notice a crate labelled "fire" in the back. The supposed destination is the interrogation room.'), nl, assert(holding(molotov)).

/* Easter Egg */

fire :- holding(molotov), i_am_at(interrogation_room), write('The entire room is burning! Unfortunately, that includes you!'), die, nl.


/* This rule describes how to enter a password */

enter_password(Password) :- i_am_at(operation_room), Password = 'turing', write('Correct! There are huge transfers to powerful politicians in Europe and the USA. These guys use politicians as puppets. You should probably take the computer with you.').

/* This rule describes how to combine objects */

combine(gun, spray_can) :- holding(gun), holding(spray_can), retract(holding(gun)), retract(holding(spray_can)), assert(holding(silenced_gun)), !.
combine(spray_can, gun) :- holding(gun), holding(spray_can), retract(holding(gun)), retract(holding(spray_can)), assert(holding(silenced_gun)).

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

u :- go(u).

d :- go(d).

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
		write('You died!'),
		retract(dialogue_done(interrogation_room)), /*useful for debugging*/
        finish.


/* Under UNIX, the 'halt.' command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final 'halt.' */

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
        write('choose(Option)               -- to choose a presented option'), nl,
        write('investigate(Object)          -- to investigate an object'), nl,
		write('inventory.                   -- to go through your inventory.'), nl,
        write('look.                        -- to look around you again.'), nl,
        write('connect_wires(Wire1, Wire2). -- to connect 2 wires'), nl,
        write('flip_switch.                 -- to flip a switch'), nl,
        write('enter_password(Password).    -- to enter a password'), nl,
        write('combine(Object1, Object2)    -- to combine 2 objects'), nl,
		write('instructions.                -- to see this message again.'), nl,
        write('halt.                        -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description.

   Possible paths are ordered n, e, s, w, u, d
*/

describe(interrogation_room) :- dialogue_done(interrogation_room), write('The entire room you are in looks old and abondened. To the north is a door.'), !, nl.
describe(interrogation_room) :- write('You wake up and find yourself tied to a shabby wooden chair with ropes. Your wrists are connected to some sort of machine with cables. You can spot bits of the cable where the copper wires are partially exposed. The entire room you are in looks old and abondened. To the north is a door, which appears to be unlocked. Between you and the door water is dripping down from an old, rusty pipe, forming a puddle of formidable size.'), !, nl.

describe(workshop) :- write('This room looks just as bad as everything else in this building. Broken tools are lying around everywhere. Something possibly resembling a crowbar is lying on the floor. There is also an spray can laying on the ground, which could be combined with something else.'), !, nl.

describe(east_staircase_lower) :- write('Here the staircase only leads upwards. To the west is hallway L4.'), !, nl.

describe(east_staircase_upper) :- write('You reach the upper floor, but the stairs to the first floor are destroyed so that you can only go downwards. You can go west to look around the corner.'), !, nl.

describe(electrical_room) :- write('With wires hanging from the ceiling and broken fuzes lying around, this room appears messy and dark. An electrical box to your left catches your attention as it doesn''t look old and shabby like everything else.'), !, nl.

describe(party_room) :- write('A strong smell of booze almost knocks you unconscious. The room is filled with knocked over tables, plastic cups and empty bottles. Investigating a cupboard in the back may provide something useful.'), !, nl.

describe(jail) :- write('Inside the small cell you find two men cowering on the floor with their hands tied to their backs.'), !, nl.

describe(janitor_room) :- write('When you open the door it looks just like a typical janitor room with a mop, a buck, etc. There is also a key that could be useful.'), !, nl.

describe(office_room) :- write('This room seems to have been converted from a living room to an office with documents lying all over the place. Maybe they are worth investigating.'), !, nl.

describe(upper_exit) :- (holding(gun); holding(silenced_gun)), write('You open the door and give the 2 guards clean headshots. You finally step into freedom...'), !, nl, end.
describe(upper_exit) :- write('You open the door but with nothing to fight with the 2 guards make your body look like swiss cheese quite quickly. After you drop to the ground they finish you with a headshot.'), !, nl, die.

describe(operation_room) :- write('You open the door and find 2 LASKians immediately noticing you and starting to draw their guns').
describe(operation_room) :- holding(gun), write('leaving you no choice but to gun them down. You take a deep breath but you hear people running through the hallways. As they come around the corner you start shooting at them. Unfortunately, you are heavily outnumbered and outgunned. Out of all the bullets that hit you, one goes through your head killing you.'), !, nl, die.
describe(operation_room) :- holding(silenced_gun), write('but with your silenced gun you manage to kill them without making much noise. You close the door and take care of the bodies. This room seems to be their operation room so there are a lot of things worth investigating like the shelf, the desk and the computer on top if it.'), !, nl.
describe(operation_room) :- write('. With nothing to defend yourself they make your body look like swiss cheese quite quickly. After you drop to the ground they finish you with a headshot.'), !, nl, die.

describe(living_room) :- write('You open the door and find a LASKian sitting on a couch and eating door. While he is still occupied you slowly creep toward him and snap his neck from behind. As you hide his body you notice his handgun which could come in handy in the near future. There doesn''t seem to be anything useful in this room.'), !, nl.

describe(hallway_l1) :- write('You are in hallway L1. To the east is hallway L2. To the south is hallway L7. To the west is an emergency exit.'), !, nl.
describe(hallway_l2) :- write('You are in hallway L2. To the north is a room that appears to serve as a prison. To the east is hallway L3. To the west is hallway L1.'), !, nl.
describe(hallway_l3) :- write('You are in hallway L3. To the east is hallway L4. To the south is a dark room stinking of booze. To the west is  hallway L2.'), !, nl.
describe(hallway_l4) :- write('You are in hallway L4. To the east is a staircase. To the south is hallway L5. To the west is hallway L3.'), !, nl.
describe(hallway_l5) :- write('You are in hallway L5. To the south is the interrogation room. To the west is hallway L6. To the north is L4.'), !, nl.
describe(hallway_l6) :- write('You are in hallway L6. To the north is a door leading to an electrical room. To the east is hallway L5. To the south are double doors leading to a workshop. To the west is hallway L7.'), !, nl.
describe(hallway_l7) :- write('You are in hallway L7. To the north is hallway L1. To the east is hallway L6.'), !, nl.

describe(hallway_u1) :- write('You are in hallway U1. To the south is hallway U2. To the east is the staircase.'), !, nl.
describe(hallway_u2) :- write('You are in hallway U2. To the south is hallway U3. To the west is hallway U4. To the north is hallway U1.'), !, nl.
describe(hallway_u3) :- write('You are in hallway U3. To the south is a door leading outside with what looks like armored guards next to it (outside). To the east is a door with a sign next to it that says JANITOR. To the north is hallway U2.'), !, nl.
describe(hallway_u4) :- write('You are in hallway U4. To the west is hallway U5. To the south is a typical hotel door. To the north is a suspicious looking door. To the east is hallway U2.'), !, nl.
describe(hallway_u5) :- write('You are in hallway U5. To the south is a typical hotel door. To the west is hallway U6.'), !, nl.
describe(hallway_u6) :- write('You are at the end of the hallway. The only way is back to hallway U5 in the east.'), !, nl.

/* backup if we forget to describe a room */
describe(X) :- write('You are at:'), write(X), nl.


/* wire puzzle */

turn_on_light(Color) :- light_on(Color), !; assert(light_on(Color)).

connect_wires(WireX, WireY) :- equals_green(WireX, WireY), turn_on_light(green), write('The green light turns on.'), !;
                               eqauls_orange(WireX, WireY), turn_on_light(orange), write('The orange light turns on.'), !;
                               eqauls_purple(WireX, WireY), turn_on_light(purple), write('The purple light turns on.'), !.
connect_wires(_, _) :- write('Nothing happens.').

flip_switch :- light_on(green), light_on(orange), light_on(purple), assert(is_open(lower_exit)), write('You hear clogs turning.'), nl, !.
flip_switch :- write('Nothing happens.').


/* ending */

end :- write('malus necessarium - the end'), nl, write('Hi, my name is Cohen. I''m a responsible for new recruits at Azul Blanco. This was all a test. You escaped. Congratulations.'), nl, print_evidence_score, print_hostage_score, finish.

print_evidence_score :- holding(shelf_documents), holding(desk_documents), write('You secured all evidence. Excellent work!'), nl, !.
print_evidence_score :- write('It seems that you failed to secure all evidence.'), nl.

print_hostage_score :- colleague_killed, write('Why did you kill your fellow Tiro? Don''t you trust your colleagues?'), nl, !.
print_hostage_score :- colleague_rescued, write('You have rescued your fellow Tiro. Well done!'), nl, !.
print_hostage_score :- write('You eihter missed the hostage or just left him in there. Disappointing'), nl.

/* interactions */

dialogue_exists(interrogation_room).
dialogue_exists(jail).

dialogue(Place) :- (\+(dialogue_exists(Place)) ; dialogue_done(Place)), !.
dialogue(Place) :- print_dialogue(Place), print_options(Place), assert(dialogue_done(Place)).

print_options(interrogation_room) :- print_options(1_1).

print_dialogue(interrogation_room) :- write("Good evening Tiro FE9. Do you have any clue why you are here tonight? Well, how should you?"), nl, write("I know that you are a Tiro of Azul Blanco and as you might have guessed, that is a minor inconvenience for me. I have a few questions for you now. You better answer correctly, you won´t fancy the alternative. See this machine over there? ICA approved lie detector, shocks you if you lie. One of your friends has already tested that. Let´s say, it didn´t exactly work out for him. The other friend of yours, on the contrary, chose to cooperate. Smart guy! Choice is yours..."), nl, assert(dialogue_stage(1_1)), !.
print_options(1_1) :- write("    1. Provocate him"), nl, write("    2. Initiate talk"), nl, !.
choose(1) :- dialogue_stage(1_1), retract(dialogue_stage(1_1)), assert(dialogue_stage(1_2)), print_dialogue(1_2), print_options(1_2), !.
	print_dialogue(1_2) :- write("As if I believed a word coming from such a bloody c*nt like you. Who the f*ck do you think you are, thinking you could threaten me like that?"), nl, write("ZAP"), nl, write("Your entire body twitches. It seriously hurts."), nl, write("You fookin´ nonce. You think you´re smart, ey? Lemme tell you something. You´re not in charge here. NOW TALK!"), nl, !.
	print_options(1_2) :- write("    1. Provocate him"), nl, write("    2. Initiate talk"), nl, !.
	choose(1) :- dialogue_stage(1_2), retract(dialogue_stage(1_2)), assert(dialogue_stage(1_3)), print_dialogue(1_3), print_options(1_3), !.
		print_dialogue(1_3) :- write("Could you come a lil´ closer, I didn´t hear you."), nl, write("The interrogater walks towards you. You hear a silent splash."), nl, !.
		print_options(1_3) :- write("    1. Attack him"), nl, write("    2. Tell a lie"), nl, !.
		choose(1) :- dialogue_stage(1_3), retract(dialogue_stage(1_3)), write("You manage to land a near perfect kick on his knee. You manage to dislocate it. He tumbles and drops to the ground. You hit him over the head with your chair. He drops unconscious, the chair brakes, you free yourself from your ties."), nl, retract(interaction_mode(player)), look, !.
		choose(2) :- dialogue_stage(1_3), retract(dialogue_stage(1_3)), write("LASK is superior to Blau-Weiss."), nl, write("ZAAAP! The lie detector overcharges and electrocutes the puddle (due to the exposed cable bits), in which the interrogater is standing. He drops to the floor. Although his body´s still twitching, he´s surely dead."), nl, retract(interaction_mode(player)), look, !.
	choose(2) :- dialogue_stage(1_1), retract(dialogue_stage(1_1)), nl, assert(dialogue_stage(1_4)), print_options(1_4), !.
choose(2) :- dialogue_stage(1_2), retract(dialogue_stage(1_2)), nl, assert(dialogue_stage(1_4)), print_options(1_4), !.
	print_options(1_4) :- write("    1. Ask for evidence about colleagues"), nl, write("    2. Ask for a question"), nl, !.
	choose(1) :- dialogue_stage(1_4), retract(dialogue_stage(1_4)), assert(dialogue_stage(1_5)), print_dialogue(1_5), print_options(1_5), !.
		print_dialogue(1_5) :-  write("I don´t believe you, show me evidence that you even have captured the other Tiros."), nl, write("Very well, make yourself comfortable in the meantime."), nl, write("The interrogater leaves the room"), nl, !.
		print_options(1_5) :- write("    1. Try to untie yourself"), nl, write("    2. Wait for the interrogater"), nl, !.
		choose(1) :- dialogue_stage(1_5), retract(dialogue_stage(1_5)), assert(dialogue_stage(1_6)), print_dialogue(1_6), print_options(1_6), !.
			print_dialogue(1_6) :- write("You have managed to untie yourself."), nl, !.
			print_options(1_6) :- write("    1. Trap the interrogater"), nl, write("    2. Flee"), nl, !.
			choose(1) :- dialogue_stage(1_6), retract(dialogue_stage(1_6)), write("As the interrogater enters the room you strangle him with the rope you were tied up with. The rope breaks, but you manage to subdue the interrogater anyhow."), nl, retract(interaction_mode(player)), look, !.
			choose(2) :- dialogue_stage(1_6), retract(dialogue_stage(1_6)), write("Through bad luck, you run into the interrogater while trying to flee. He sounds the alarm. Seconds later guards swarm the floor and shoot you."), nl, die, !.
		choose(2) :- dialogue_stage(1_5), retract(dialogue_stage(1_5)), assert(dialogue_stage(1_7)), print_dialogue(1_7), print_options(1_7), !.
	choose(2) :- dialogue_stage(1_4), retract(dialogue_stage(1_4)), assert(dialogue_stage(1_7)), print_dialogue(1_7), print_options(1_7), !.
		print_dialogue(1_7) :-  write("What do you want from me?"), nl, write("The Lynn-Incident. Rings a bell?"), nl, !.
		print_options(1_7) :- write("    1. Talk"), nl, write("    2. Lie"), nl, write("    3. Remain silent"), nl, !.
		choose(1) :- dialogue_stage(1_7), retract(dialogue_stage(1_7)), write("Long time ago. I don´t really know anything that I have not learned from the news."), nl, write("The lie detector does nothing"), nl, write("Very well, thank you for your cooperation. You´re no longer worth anything to me anymore."), nl, write("The interrogater turns up the voltage to the maximum."), nl, die, !.
		choose(2) :- dialogue_stage(1_7), retract(dialogue_stage(1_7)), assert(dialogue_stage(1_8)), print_dialogue(1_8), print_options(1_8), !.																/*rewrite*/
			print_dialogue(1_8) :-  write("As much as you want to know, but you better take notes, I will only tell you once."), nl, write("Alright."), nl, write("The interrogater leaves the room. The lie detector fires a delayed shock breaking apart the rope, with which you´re tied up with, and fall off."), nl, !.
			print_options(1_8) :- write("    1. Trap the interrogater"), nl, write("    2. Flee"), nl, !.
			choose(1) :- dialogue_stage(1_8), retract(dialogue_stage(1_8)), write("As the interrogater enters the room you strangle him with the rope you were tied up with. The rope breaks, but you manage to subdue the interrogater anyhow."), nl, retract(interaction_mode(player)), look, !.
			choose(2) :- dialogue_stage(1_8), retract(dialogue_stage(1_8)), write("Through bad luck, you run into the interrogater while trying to flee. He sounds the alarm. Seconds later guards swarm the floor and shoot you."), nl, die, !.
		choose(3) :- dialogue_stage(1_7), retract(dialogue_stage(1_7)), write("..."), nl, write("I have warned you, but you don´t seem to listen. Chosen your own fate, huh?"), nl, write("The interrogater turns up the voltage to the maximum."), nl, die, !.

print_dialogue(jail) :- write('One of the two men appears to be dead. The other one seems to be unconscious.'), nl.
print_options(jail) :- write('    1. Kill the unconscious man too'), nl, write('    2. Rescue the unconscious man'), nl, write('    3. Leave them alone').
choose(1) :- write('Sandman brings a bad dream - You snap the sleeping man''s neck.'), assert(colleague_killed).
choose(2) :- write('You lift his unconscious body up and carry him on your shoulder.'), assert(colleague_rescued).
choose(3) :- write('Nothing happens.').
