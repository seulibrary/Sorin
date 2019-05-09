# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Core.Repo.insert!(%Core.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Core.Dashboard

##################################
#  ADD USERS
############
[
  ["user1@email.com", "User 1"],
  ["user2@email.com", "User 2"],
  ["user3@email.com", "User 3"],
]
|> Enum.each(fn [email, fullname] ->
  Core.Accounts.make_user(email, fullname) end)

##################################
# MAKE NEW COLLECTIONS
######################

Dashboard.Collections.new_collection(1, "Gaming") # -> Collection no. 4
Dashboard.Collections.new_collection(1, "Software Engineering") # -> 5
Dashboard.Collections.new_collection(2, "Dogs") # -> 6
Dashboard.Collections.new_collection(2, "Design") # -> 7
Dashboard.Collections.new_collection(3, "Proust") # -> 8
Dashboard.Collections.new_collection(3, "John Cage") # -> 9

###################################
# ADD TAGS
##########

# User 1 - Gaming
Dashboard.Collections.add_tag_to_collection("Fun", 4)
Dashboard.Collections.add_tag_to_collection("Politics", 4)

# User 1 - Software Engineering
Dashboard.Collections.add_tag_to_collection("Code", 5)
Dashboard.Collections.add_tag_to_collection("Elixir", 5)
Dashboard.Collections.add_tag_to_collection("Memory", 5)

# User 2 - Dogs
Dashboard.Collections.add_tag_to_collection("Fun", 6)
Dashboard.Collections.add_tag_to_collection("Zen", 6)

# User 2 - Design
Dashboard.Collections.add_tag_to_collection("Code", 7)
Dashboard.Collections.add_tag_to_collection("Art", 7)

# User 3 - Proust
Dashboard.Collections.add_tag_to_collection("Memory", 8)
Dashboard.Collections.add_tag_to_collection("Politics", 8)

# User 3 - John Cage
Dashboard.Collections.add_tag_to_collection("Art", 9)
Dashboard.Collections.add_tag_to_collection("Zen", 9)

###################################
# ADD NOTES TO COLLECTIONS
###########

# User 1 - Gaming
Dashboard.Collections.add_note(4, "While films are a very visual and emotional artistic medium, video games take it one step further into the realm of a unique personal experience. - Jet Li")

# User 1 - Software Engineering
Dashboard.Collections.add_note(5, "Object-oriented programming is an exceptionally bad idea which could only have originated in California. --Edsger Dijkstra")

# User 2 - Dogs
Dashboard.Collections.add_note(6, "Dogs have boundless enthusiasm but no sense of shame. I should have a dog as a life coach. -- Moby")

# User 2 - Design
Dashboard.Collections.add_note(7, "Space is the breath of art. -- Frank Lloyd Wright")

# User 3 - Proust
Dashboard.Collections.add_note(8, "The laws of memory are subject to the more general laws of habit. Habit is a compromise effected between the individual and his environment, or between the individual and his own organic eccentricities, the guarantee of a dull inviolability, the lightning-conductor of his existence. Habit is the ballast that chains the dog to his vomit. Breathing is habit. Life is habit. Or rather life is a succession of habits, since the individual is a succession of individuals; the world being a projection of the individual’s consciousness (an objectivation of the individual’s will, Schopenhauer would say), the pact must be continually renewed, the letter of safe-conduct brought up to date. The creation of the world did not take place once and for all time, but takes place every day. Habit then is the generic term for the countless treaties concluded between the countless subjects that constitute the individual and their countless correlative objects. -- Beckett")

# User 3 - John Cage
Dashboard.Collections.add_note(9, "If something is boring after two minutes, try it for four. If still boring, then eight. Then sixteen. Then thirty-two. Eventually one discovers that it is not boring at all. -- John Cage")

####################################
# PUBLISH COLLECTIONS
#####################

Dashboard.Collections.publish_collection(5) # User 1, Software
Dashboard.Collections.publish_collection(7) # User 2, Design
Dashboard.Collections.publish_collection(8) # User 3, Proust
Dashboard.Collections.publish_collection(9) # User 3, Proust

####################################
# SET COLLECTION COLORS
################

Dashboard.Collections.set_collection_color(5, 1, "#cef79f") # User 1, Software
Dashboard.Collections.set_collection_color(7, 2, "#f9c732") # User 2, Design
Dashboard.Collections.set_collection_color(8, 3, "#f59374") # User 3, Proust

####################################
# SHARE COLLECTIONS
#######

# Not yet available in the front end

####################################
# ARCHIVE COLLECTIONS
#########

# Not yet available in the front end

#####################################
# ADD RESOURCES
###############

# User 1, Gaming (4)
# 1
Core.Resources.create_resource(
  %{"collection_id" => 4,
    "collection_index" => 0,
    "contributor" => nil,
    "creator" => ["Oxlade, Chris."],
    "date" => "2012",
    "description" => "\"Describes the technology used for creating and playing video games. Includes information on how different platforms work and the direction video game technology may be going\"--Provided by publisher.",
    "format" => "46 pages : color illustrations ; 28 cm.",
    "language" => "eng",
    "publisher" => "Smart Apple Media",
    "subject" => ["Computer games--Programming--Juvenile literature.",
		  "Video games--Technological innovations--Juvenile literature."],
    "title" => "Gaming technology ",
    "type" => "Text"
  })

# 2
Core.Resources.create_resource(
  %{"collection_id" => 4,
    "collection_index" => 1,
    "contributor" => ["ProQuest (Firm)"],
    "creator" => ["Carless, Simon."],
    "date" => "2005",
    "description" => "\"100 industrial-strength tips & tools\"--Cover.",
    "format" => "1 online resource (xxiii, 436 p. :) ill.",
    "language" => "eng",
    "publisher" => "O'Reilly",
    "subject" => ["Computer games--Programming.", "Video games."],
    "title" => "Gaming hacks",
    "type" => "Text"
  })

# 3
Core.Resources.create_resource(
  %{"collection_id" => 4,
    "collection_index" => 2,
    "contributor" => nil,
    "creator" => ["Mason, W. Dale (Walter Dale), 1951-"],
    "date" => "2000",
    "description" => "Indian Policy and Conflict in the American Political System -- Indian Gaming: The Law, the Interests, and the Scope of Conflict -- New Mexico: Gaming and Hardball Politics -- ''We'll Remember in November\" -- A Clash of Sovereigns, A Clash of History.",
    "format" => "1 online resource (xxi, 330 pages) : illustrations",
    "language" => "eng",
    "publisher" => "University of Oklahoma Press",
    "subject" => ["Indians of North America--Gambling--New Mexico.",
		  "Indians of North America--Gambling--Oklahoma.",
		  "Indian business enterprises--New Mexico.",
		  "Indian business enterprises--Oklahoma.",
		  "Indians of North America--New Mexico--Politics and government.",
		  "Indians of North America--Oklahoma--Politics and government."],
    "title" => "Indian gaming : tribal sovereignty and American politics ",
    "type" => "Text"
  })

# User 1, Software Engineering (5)
# 4
Core.Resources.create_resource(
  %{"collection_id" => 5,
    "collection_index" => 0,
    "contributor" => nil,
    "creator" => ["Weinberg, Gerald M."],
    "date" => nil,
    "description" => "This landmark 1971 classic is reprinted with a new preface, chapter-by-chapter commentary, and straight-from-the-heart observations on topics that affect the professional life of programmers.Long regarded as one of the first books to pioneer a people-oriented approach to computing, The Psychology of Computer Programming endures as a penetrating analysis of the intelligence, skill, teamwork, and problem-solving power of the computer programmer.Finding the chapters strikingly relevant to today's issues in programming, Gerald M. Weinberg adds new insights and highlights the similarities and differences between now and then. Using a conversational style that invites the reader to join him, Weinberg reunites with some of his most insightful writings on the human side of software engineering.Topics include egoless programming, intelligence, psychological measurement, personality factors, motivation, training, social problems on large projects, problem-solving ability, programming language design, team formation, the programming environment, and much more.The author says, \"On an inspired eight-week vacation in Italy, I wrote the first draft of The Psychology of Computer Programming. . . . the book quickly became a best-seller among technical titles, running through more than twenty printings and staying in print for twenty-five years. . . .\"For this Silver Anniversary Edition, I decided to take my own advice and not try to hide my errors, for they would be the source of the most learning for my readers. I decided to leave the original text as it was⁰́₄antiques and all⁰́₄for your illumination, and simply to add some 'wisdom of hindsight' remarks whenever the spirit moved me. I hope you find the perspective brought by this time-capsule contrast as useful to you as it has been to me.\"J.J. Hirschfelder of Computing Reviews wrote: \"The Psychology of Computer Programming . . . was the first major book to address programming as an individual and team effort, and became a classic in the field. . . . Despite, or perhaps even because of, the perspective of 1971, this book remains a must-read for all software development managers.\"Sue Petersen of Visual Developer said: \"In this new edition, Jerry looks at where we were 30 years ago, where we are now and where we might be in the future. Instead of changing the original text, he's added new comments to each chapter. This allows the reader to compare and contrast his thinking over the decades, showcasing the errors and omissions as well as the threads that bore fruit.\". . . one issue ⁰́₄ communication ⁰́₄ has been at the core of Jerry's work for decades. Unknown to him at the time, Psychology was to form the outline of his life's work. . . . Psychology is valuable as history in a field that is all too ready to repeat the errors of its past. Read Psychology as a picture of where we've been, where we are now, and where we need to go next. Read it as an index to the thinking of one of the most influential figures in our field.\"",
    "format" => "1 online resource.",
    "language" => "eng",
    "publisher" => nil,
    "subject" => ["Computer programming--Psychological aspects."],
    "title" => "The Psychology of Computer Programming Silver Anniversary eBook Edition ",
    "type" => "Text"
  })

# 5
Core.Resources.create_resource(
  %{"collection_id" => 5,
    "collection_index" => 1,
    "contributor" => nil,
    "creator" => ["Pitt, D.,"],
    "date" => "2007",
    "description" => nil,
    "format" => "1 online resource (532 pages).",
    "language" => "eng",
    "publisher" => "Springer",
    "subject" => ["Computer programming.", "Categories (Mathematics)"],
    "title" => "Category Theory and Computer Programming.",
    "type" => "Text"
  }
)

# 6
Core.Resources.create_resource(
  %{"collection_id" => 5,
    "collection_index" => 2,
    "contributor" => ["Knuth, Donald Ervin Mathématicien, 1938-",
		      "Knuth, Donald Ervin Mathematician, 1938-",
		      "Knuth, Donald Ervin Mathematiker, 1938-"],
    "creator" => nil,
    "date" => "2012",
    "description" => nil,
    "format" => "441 Seiten : Illustrationen.",
    "language" => "eng",
    "publisher" => "CSLI",
    "subject" => ["Computer algorithms.", "Computer programming."],
    "title" => "Companion to the papers of Donald Knuth ",
    "type" => "Text"
  }
)

# User 2, Dogs (6)
# 7
Core.Resources.create_resource(
  %{"collection_id" => 6,
    "collection_index" => 0,
    "contributor" => nil,
    "creator" => ["Hobgood-Oster, Laura, 1964-"],
    "date" => nil,
    "description" => nil,
    "format" => "xi, 188 pages : illustrations ; 22 cm",
    "language" => "eng",
    "publisher" => nil,
    "subject" => ["Dogs.", "Dogs--History.", "Dog owners.",
		  "Human-animal relationships."],
    "title" => "A dog's history of the world: canines & the domestication of humans ",
    "type" => "Text"
  }
)

# 8
Core.Resources.create_resource(
  %{"collection_id" => 6,
    "collection_index" => 1,
    "contributor" => ["Metropolitan Museum of Art (New York, N.Y.)"],
    "creator" => nil,
    "date" => "2006",
    "description" => nil,
    "format" => "1 v. : col. ill. ; 14 x 16 cm.",
    "language" => "eng",
    "publisher" => "Chronicle Books",
    "subject" => ["Metropolitan Museum of Art (New York, N.Y.)",
		  "Dogs in art.", "Dogs--Quotations, maxims, etc.",
		  "Art--New York (State)--New York."],
    "title" => "The artful dog: canines from the Metropolitan Museum of Art.",
    "type" => "Text"
  }
)

# 9
Core.Resources.create_resource(
  %{"collection_id" => 6,
    "collection_index" => 2,
    "contributor" => nil,
    "creator" => ["Smith, Cheryl."],
    "date" => "2004",
    "description" => nil,
    "format" => "256 pages",
    "language" => "eng",
    "publisher" => "Wiley",
    "subject" => ["Dogs--Training.", "Human-animal communication."],
    "title" => "The rosetta bone: the key to communication between humans and canines ",
    "type" => "Text"
    }
)

# User 2, Design (7)
# 10
Core.Resources.create_resource(
  %{"collection_id" => 7,
    "collection_index" => 0,
    "contributor" => ["Hudert, Markus.", "Agkathidis, Asterios."],
    "creator" => ["Schillig, Gabi."],
    "date" => "2012",
    "description" => nil,
    "format" => "126 pages",
    "language" => "eng",
    "publisher" => "Ernst J. Wasmuth Verlag GmbH & Company",
    "subject" => ["Architectural design--Methodology."],
    "title" => "Form Defining Strategies: Experimental Architectural Design.",
    "type" => "Text"
    }
)

# 11
Core.Resources.create_resource(
  %{"collection_id" => 7,
    "collection_index" => 1,
    "contributor" => nil,
    "creator" => ["Burry, Mark."],
    "date" => "2013",
    "description" => "With scripting, computer programming becomes integral to the digital design process. It provides unique opportunities for innovation, enabling the designer to customise the software around their own predilections and modes of working. It liberates the designer by automating many routine aspects and repetitive activities of the design process, freeing-up the designer to spend more time on design thinking. Software that is modified through scripting offers a range of speculations that are not possible using the software only as the manufacturers intended it to be used. There are also significant.",
    "format" => "1 online resource (271 pages).",
    "language" => "eng",
    "publisher" => "Wiley",
    "subject" => ["Architectural design.", "Computer-aided design.",
		  "Architectural models.", "Architecture, Modern--21st century."],
    "title" => "Scripting Cultures: Architectural Design and Programming.",
    "type" => "Text"
  }
)

# 12
Core.Resources.create_resource(
  %{"collection_id" => 7,
    "collection_index" => 2,
    "contributor" => ["Boot, R.,", "National Computing Centre Limited."],
    "creator" => nil,
      "date" => "1973",
    "description" => nil,
    "format" => "165 pages illustrations 31 cm.",
    "language" => "eng",
    "publisher" => "NCC Publications",
    "subject" => ["Computer programming--Congresses.",
		  "System analysis--Congresses.",
		  "Electronic digital computers--Design and construction--Congresses."],
    "title" => "Approaches to systems design.",
    "type" => "Text"
  }
)

# User 3, Proust (8)
# 13
Core.Resources.create_resource(
  %{"collection_id" => 8,
    "collection_index" => 0,
    "contributor" => nil,
    "creator" => ["Landy, Joshua."],
    "date" => "2009",
    "description" => nil,
    "format" => "x, 255 pages ; 23 cm",
    "language" => "eng",
    "publisher" => "Oxford University Press",
    "subject" => ["Self in literature.", "Deception in literature.",
		  "Knowledge, Theory of, in literature.", "Proust, Marcel."],
    "title" => "Philosophy as fiction: self, deception, and knowledge in Proust.",
    "type" => "Text"
  }
)

# 14
Core.Resources.create_resource(
  %{"collection_id" => 8,
    "collection_index" => 1,
    "contributor" => nil,
    "creator" => ["Connor, Steven, 1955-"],
    "date" => "2007",
    "description" => "Difference and repetition -- Economies of repetition -- Repetition in time : Proust and Molloy -- Centre, line, circumference : repetition in the trilogy -- Repetition and self-translation : Mercier and Camier, First love, The lost ones -- Presence and repetition in Beckett's theatre -- What? where? : space and the body -- Repetition and power.",
    "format" => "1 online resource (xvi, 243 pages).",
    "language" => "eng",
    "publisher" => "Davies Group",
    "subject" => ["Beckett, Samuel, 1906-1989--Technique.",
		  "Repetition (Rhetoric)"],
    "title" => "Samuel Beckett: repetition, theory, and text ",
    "type" => "Text"
  }
)

# 15
Core.Resources.create_resource(
  %{"collection_id" => 8,
    "collection_index" => 2,
    "contributor" => ["Howard, Richard"],
    "creator" => ["Deleuze, Gilles"],
    "date" => nil,
    "description" => "In a remarkable instance of literary and philosophical interpretation, the incomparable Gilles Deleuze reads Marcel Proust's work as a narrative of an apprenticeship-more precisely, the apprenticeship of a man of letters. Considering the search to be one directed by an experience of signs, in which the protagonist learns to interpret and decode the kinds and types of symbols that surround him, Deleuze conducts us on a corollary search-one that leads to a new understanding of the signs that constitute A la recherche du temps perdu. In Richard Howard's graceful translation, augmented with an ess ...",
    "format" => "1 online resource (204 Seiten)",
    "language" => "eng",
    "publisher" => nil,
    "subject" => nil,
    "title" => "Proust And Signs: The Complete Text",
    "type" => "Text"
  }
)

# User 3. John Cage (9)
# 16
Core.Resources.create_resource(
  %{"collection_id" => 9,
    "collection_index" => 0,
    "contributor" => nil,
    "creator" => ["Joseph, Branden Wayne,"],
    "date" => nil,
    "description" => "Machine generated contents note: 1. Therapeutic Value for City Dwellers: John Cage's Early Avant-Garde Aesthetic -- 2. Hitchhiker in an Omni-Directional Transport: The Spatial Politics of John Cage and Buckminster Fuller -- 3. Architecture of Silence -- 4. Chance, Indeterminacy, Multiplicity -- 5. HPSCHD-Ghost or Monster?",
    "format" => "1 online resource (xiv, 217 pages)",
    "language" => "eng",
    "publisher" => nil,
    "subject" => ["Cage, John--Criticism and interpretation.",
		  "Cage, John--Influence.",
		  "Fuller, R. Buckminster (Richard Buckminster), 1895-1983.",
		  "Cage, John. HPSCHD.", "Avant-garde (Music)--History--20th century.",
		  "Avant-garde (Aesthetics)--United States--History--20th century.",
		  "Music--20th century--Philosophy and aesthetics.", "Art and music.",
		  "Music and architecture.", "Aleatory music--History and criticism."],
    "title" => "Experimentations: John Cage in music, art, and architecture ",
    "type" => "Text"
  }
)

# 17
Core.Resources.create_resource(
  %{"collection_id" => 9,
    "collection_index" => 1,
    "contributor" => nil,
    "creator" => ["Baofu, Peter."],
    "date" => "2012",
    "description" => "Are the performing arts really supposed to be so radical that, as John Cage once said in the context of music, \"\"there is no noise, only sound, \"\" since \"\"he argued that any sounds we can hear can be music\"\"? (WK 2007a; D. Harwood 1976) This radical tradition.",
    "format" => "1 online resource (xxii, 559 pages)",
    "language" => "eng",
    "publisher" => "Cambridge Scholars Pub",
    "subject" => ["Performing arts--Philosophy.", "Performance.",
		  "Forecasting."],
    "title" => "Future of post-human performing arts : a preface to a new theory of the body and its presence ",
    "type" => "Text"
  }
)

# 18
Core.Resources.create_resource(
  %{"collection_id" => 9,
    "collection_index" => 2,
    "contributor" => nil,
    "creator" => ["Botha, Marc,"],
    "date" => nil,
    "description" => "1. Intermittency : on the transhistoricism of minimalism. 1.1 Minimum. Minimalism as existential modality : Frans Vanderlinde's Elimination/Incarnation (1967) ; 1.2 Intermittency. The transhistorical register of minimalism : Dan Flavin's monument 1 to V. Tatlin (1964) ; 1.3 Margins. At the periphery of minimalism : Robert Hooke's Micrographia (1655) ; John Lee Byars's The book of the hundred questions (1969) ;1.4 Movement. Minimalism as a dynamic movement : La Monte Young's Trio for strings (1958) ; 1.5 Minimalism. Name as paradigm : Donald Judd's Untitled (Stack) (1967) ; 1.6 Transition. Between modernism and postmodernism : Ronaldo Azeredo's VELOCIDADE (1957) ; Ai Weiwei's A ton of tea (2007) -- 2. Encounters : on the politics of minimalism. 2.1 Threshold. Between art and non-art : Carl Andre's Venus Forge (1980) ; 2.2 Encounter. Minimalism and the sustained encounter : La Monte Young's Dream Houses (1966-70) ; 2.3 Perception. Embodied perception as a generative process : Robert Morris's untitled (3 Ls) (1965-70) ; 2.4 Disruption. Minimalism and the politics of public space : Richard Serra's Tilted Arc (1981) ; 2.5 Force. Micro-political apertures to macro-political events : Frank Stella's Arbeit Macht Fret (1967) ; 2.6 Anticipation. Unexpected epiphanies and the politics of the everyday : Raymond Carver's 'Fat' (1971).",
    "format" => "xviii, 279 pages ; 25 cm",
    "language" => "eng",
    "publisher" => nil,
    "subject" => ["Minimal art.", "Aesthetics, Modern--20th century."],
    "title" => "A theory of minimalism ",
    "type" => "Text"
  }
)

#################################
# ADD NOTES AND TAGS TO RESOURCES
##################

# User 1
Dashboard.Resources.add_note(6, "Creator of TeX")
Dashboard.Resources.add_tag_to_resource(6, "Algorithms")
Dashboard.Resources.add_tag_to_resource(6, "Knuth")

# User 2
Dashboard.Resources.add_note(11, "Scripting and automation for design processes")
Dashboard.Resources.add_tag_to_resource(11, "Design")
Dashboard.Resources.add_tag_to_resource(11, "Automation")

# User 3
Dashboard.Resources.add_note(15, "Proust's prose itself as a rhizomatic system, a nomadic war machine?")
Dashboard.Resources.add_tag_to_resource(15, "Memory")
Dashboard.Resources.add_tag_to_resource(15, "Systems")

########################################
# ADD FILES TO COLLECTIONS AND RESOURCES
##############

# User 1
Dashboard.Collections.add_file(4,
  "apps/core/priv/repo/assets/file_attachments/File 1.txt", 1)
Dashboard.Collections.add_file(5,
  "apps/core/priv/repo/assets/file_attachments/File 2.txt", 1)
Dashboard.Resources.add_file(1,
  "apps/core/priv/repo/assets/file_attachments/File 3.txt", 1)
Dashboard.Resources.add_file(2,
  "apps/core/priv/repo/assets/file_attachments/File 4.txt", 1)
Dashboard.Resources.add_file(4,
  "apps/core/priv/repo/assets/file_attachments/File 5.txt", 1)

# User 2
Dashboard.Collections.add_file(6,
  "apps/core/priv/repo/assets/file_attachments/File 6.txt", 2)
Dashboard.Collections.add_file(7,
  "apps/core/priv/repo/assets/file_attachments/File 7.txt", 2)
Dashboard.Resources.add_file(7,
  "apps/core/priv/repo/assets/file_attachments/File 8.txt", 2)
Dashboard.Resources.add_file(8,
  "apps/core/priv/repo/assets/file_attachments/File 9.txt", 2)
Dashboard.Resources.add_file(10,
  "apps/core/priv/repo/assets/file_attachments/File 10.txt", 2)

# User 3
Dashboard.Collections.add_file(8,
  "apps/core/priv/repo/assets/file_attachments/File 11.txt", 3)
Dashboard.Collections.add_file(9,
  "apps/core/priv/repo/assets/file_attachments/File 12.txt", 3)
Dashboard.Resources.add_file(13,
  "apps/core/priv/repo/assets/file_attachments/File 13.txt", 3)
Dashboard.Resources.add_file(14,
  "apps/core/priv/repo/assets/file_attachments/File 14.txt", 3)
Dashboard.Resources.add_file(17,
  "apps/core/priv/repo/assets/file_attachments/File 15.txt", 3)


####################################
# CLONES
########

# User 1 clones Proust
Search.Collections.clone_collection(8, 1)

# Users 2 and 3 clone software engineering
Search.Collections.clone_collection(5, 2)
Search.Collections.clone_collection(5, 3)

####################################
# IMPORTS
#########

# User 1 imports Dogs
Search.Collections.import_collection(6, 1)

# User 2 imports John Cage
Search.Collections.import_collection(9, 2)

# User 3 imports Design
Search.Collections.import_collection(7, 3)
