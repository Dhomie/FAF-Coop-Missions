
--*****************************************************************************
--* File: C:\work\rts\main\data\maps\SCCA_Coop_R06\SCCA_Coop_R06_strings.lua
--* Author: (BOT)Sam Demulling 
--* Summary: Computer Generated operation data for C06
--*
--* This file was generated by SCUD.  Do not make manual changes to this file
--* or they will be overwritten!
--*
--* Campaign Faction: Cybran
--* Campaign Description: Cybran SP Campaign
--* Operation Name: Operation Freedom
--* Operation Description: Take Over Black Sun and launch the virus
--*
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************


OPERATION_NAME = '<LOC OPNAME_C06>Operation Freedom'
OPERATION_DESCRIPTION = 'Having the Black Sun access codes secured, Cybran forces attempt a daring operation on Earth itself to take control of Black Sun, before the UEF could fire it, and before the Aeon could destroy it. There\'s no turning back now, it\'s do or die.'



--------------------------------
-- Opnode ID: B01
-- Operational Briefing
--------------------------------

BriefingData = {
  text = {
    {phase = 0, character = '<LOC Date>Date', text = '<LOC C06_B01_000_010>Date: 14-SEPTEMBER-3844'},
    {phase = 1, character = '<LOC Brackman>Brackman', text = '<LOC C06_B01_001_010>It is almost done. I have lived for over a thousand years...a long time. I have watched the war...seen so many die. It must end. We must be free. It\'s up to you, my boy.'},
    {phase = 2, character = '<LOC Dostya>Dostya', text = '<LOC C06_B01_002_010>All of our sleeper cells on Earth have activated and are assaulting strategic UEF installations. This has allowed Jericho and his team to construct a base for you near Black Sun. They will assist in any way possible.'},
    {phase = 3, character = '<LOC Dostya>Dostya', text = '<LOC C06_B01_003_010>Your mission is to seize control of Black Sun and upload QAI\'s data-core directly into its Control Center. Firing the weapon will then release both the Quantum Virus and the Liberation Matrix.'},
    {phase = 3, character = '<LOC Brackman>Brackman', text = '<LOC C06_B01_003_020>The Gates will shut down. Everyone, everywhere, will be free. There will be peace.'},
    {phase = 4, character = '<LOC Dostya>Dostya', text = '<LOC C06_B01_004_010>You understand, Commander, this is a one-way trip. If you are successful, it will be at least five years before we can re-establish contact.'},
    {phase = 4, character = '<LOC Brackman>Brackman', text = '<LOC C06_B01_004_020>He understands, oh yes. Earth will be yours, son. The Symbionts will follow you. A new beginning, a new life. Guide Earth. Make it great.'},
    {phase = 4, character = '<LOC Dostya>Dostya', text = '<LOC C06_B01_004_030>It is time. Do svidanya, Commander. It has been an honor.'},
    {phase = 4, character = '<LOC Brackman>Brackman', text = '<LOC C06_B01_004_040>Be safe.'},
  },
  movies = {'C06_B01.sfd', 'C06_B02.sfd', 'C06_B03.sfd', 'C06_B04.sfd',},
  voice = {
    {Cue = 'C06_B01', Bank = 'C06_VO'},
    {Cue = 'C06_B02', Bank = 'C06_VO'},
    {Cue = 'C06_B03', Bank = 'C06_VO'},
    {Cue = 'C06_B04', Bank = 'C06_VO'},
  },
  bgsound = {
    {Cue = 'C06_B01', Bank = 'Op_Briefing_Vanilla'},
    {Cue = 'C06_B02', Bank = 'Op_Briefing_Vanilla'},
    {Cue = 'C06_B03', Bank = 'Op_Briefing_Vanilla'},
    {Cue = 'C06_B04', Bank = 'Op_Briefing_Vanilla'},
  },
  style = 'cybran',
}

OperationMovies = {
  postOpMovies = {
    success = {
      {vid = '/movies/FMV_Cybran_Outro_1.sfd', sfx = 'FMV_Cybran_Outro_1', sfxBank = 'FMV_BG_Vanilla', voice = 'FMV_Cybran_Outro_1', voiceBank = 'FMV_Vanilla', subtitles = 'default'},
      {vid = '/movies/FMV_Credits.sfd', sfx = 'FMV_Cybran_Credits', sfxBank = 'FMV_BG_Vanilla', voice = 'FMV_Cybran_Credits', voiceBank = 'FMV_Vanilla', subtitles = 'default'},
      {vid = '/movies/FMV_Cybran_Outro_2.sfd', sfx = 'FMV_Cybran_Outro_2', sfxBank = 'FMV_BG_Vanilla', voice = 'FMV_Cybran_Outro_2', voiceBank = 'FMV_Vanilla', subtitles = 'default'},
    },
  },
}

--------------------------------
-- Opnode ID: DB01
-- Operation Debriefing
--------------------------------

R06_DB01_010 = {
  {text = '<LOC CAMPDEB_0034>From: Elite Commander Dostya\nTo: Commander {g PlayerName}\nCongratulations, Commander! You have ended the Infinite War! You no doubt have your hands full, but if you check your aft storage compartment, you will find a very good bottle of vodka. I look forward to seeing you in a few years. Dostya.', faction = 'Cybran'},
}

R06_DB01_020 = {
  {text = '<LOC CAMPDEB_0035>To: All Cybran Commanders\nFrom: Elite Commander Dostya\nCommander {g PlayerName} failed. He was unable to spread the Quantum Virus and shut down the Gate Network. The Aeon will quickly turn its sights on us. All civilians will be evacuated to the furthest reaches of our territory. I am asking for volunteers to stay behind with me and detonate the Gates once the civilians are gone. This, combined with our delaying action, should give them some time. Make no mistake, those who volunteer will not return. ', faction = 'Cybran'},
}

--------------------------------
-- Opnode ID: D01
-- Player Death
--------------------------------



-- Player Death
C06_D01_010 = {
  {text = '<LOC C06_D01_010_010>[{i Ops}]: Commander? What\'s your status? Commander?', vid = 'C06_Ops_D01_02595.sfd', bank = 'C06_VO', cue = 'C06_Ops_D01_02595', faction = 'Cybran'},
}

--------------------------------
-- Opnode ID: M01
-- Into the Fire
--------------------------------



-- Mission begins.
C06_M01_010 = {
  {text = '<LOC C06_M01_010_010>[{i Jericho}]: Good to see you again, Commander. We\'ve set up what we could. It looks like the Aeon are giving the UEF a beating a couple clicks to the west.', vid = 'C06_Jericho_M01_00559.sfd', bank = 'C06_VO', cue = 'C06_Jericho_M01_00559', faction = 'Cybran'},
  {text = '<LOC C06_M01_010_020>[{i Ops}]: Sir, it looks like the Aeon are building some sort of...flying saucer. We don\'t know what it\'s capable of, but it\'s a safe bet it\'ll attack Black Sun. Destroy it before it can take off. It cannot be allowed to reach Black Sun! Ops out.', vid = 'C06_Ops_M01_00560.sfd', bank = 'C06_VO', cue = 'C06_Ops_M01_00560', faction = 'Cybran'},
}

-- 2 minutes after mission start
C06_M01_020 = {
  {text = '<LOC C06_M01_020_010>[{i Jericho}]: Commander, we\'ve tapped into the UEF communication system. Black Sun hasn\'t been completed, but it\'s close. I\'ll keep you updated on its progress.', vid = 'C06_Jericho_M01_00561.sfd', bank = 'C06_VO', cue = 'C06_Jericho_M01_00561', faction = 'Cybran'},
}

-- If Jericho is dead at 2 minutes
C06_M01_022 = {
  {text = '<LOC C06_M01_022_010>[{i Ops}]: We have managed to tap into the UEF\'s communication system. Black Sun isn\'t finished, but it\'s close. We will update as the situation warrants.', vid = 'C06_Ops_M01_01108.sfd', bank = 'C06_VO', cue = 'C06_Ops_M01_01108', faction = 'Cybran'},
}

-- Once the player\'s units enter LoS of any Aeon unit
C06_M01_030 = {
  {text = '<LOC C06_M01_030_010>[{i Arnold}]: So the Cybrans have decided to enter the fray. It matters not. Soon your kind will be destroyed.', vid = 'C06_Arnold_M01_00562.sfd', bank = 'C06_VO', cue = 'C06_Arnold_M01_00562', faction = 'Aeon'},
  {text = '<LOC C06_M01_030_020>[{i Aiko}]: Dammit, I don\'t need any more complications. ', vid = 'C06_Aiko_M01_00563.sfd', bank = 'C06_VO', cue = 'C06_Aiko_M01_00563', faction = 'UEF'},
}

-- If the Czar manages to take off
C06_M01_050 = {
  {text = '<LOC C06_M01_050_010>[{i Ops}]: The Aeon saucer is taking off and vectoring toward the Black Sun Control Center. Destroy it!', vid = 'C06_Ops_M01_00564.sfd', bank = 'C06_VO', cue = 'C06_Ops_M01_00564', faction = 'Cybran'},
}

-- When the Czar reaches the island
C06_M01_060 = {
  {text = '<LOC C06_M01_060_010>[{i Ops}]: The saucer is almost to the Control Center! TAKE IT OUT!', vid = 'C06_Ops_M01_00565.sfd', bank = 'C06_VO', cue = 'C06_Ops_M01_00565', faction = 'Cybran'},
}

-- Objective Reminders for PO1, #1
C06_M01_070 = {
  {text = '<LOC C06_M01_070_010>[{i Ops}]: Sir, you have to take out the saucer! Ops out. ', vid = 'C06_Ops_M01_00566.sfd', bank = 'C06_VO', cue = 'C06_Ops_M01_00566', faction = 'Cybran'},
}

-- Objective Reminders for PO1, #2
C06_M01_075 = {
  {text = '<LOC C06_M01_075_010>[{i Ops}]: Everything is riding on Black Sun, sir! We can\'t let the Aeon saucer destroy it! Ops out.', vid = 'C06_Ops_M01_01525.sfd', bank = 'C06_VO', cue = 'C06_Ops_M01_01525', faction = 'Cybran'},
}

-- Objective Reminders for PO1, GLOBAL
C06_M01_076 = {
  {text = '<LOC C06_M01_076_010>[{i Ops}]: I would suggest you check your objectives, Commander. Ops out.', vid = 'C06_Ops_M01_01535.sfd', bank = 'C06_VO', cue = 'C06_Ops_M01_01535', faction = 'Cybran'},
}

-- If Jericho gets killed 
C06_M01_080 = {
  {text = '<LOC C06_M01_080_010>[{i Jericho}]: They hit with everything... ', vid = 'C06_Jericho_M01_01105.sfd', bank = 'C06_VO', cue = 'C06_Jericho_M01_01105', faction = 'Cybran'},
}

-- The Czar reaches the Control Center and fires
C06_M01_090 = {
  {text = '<LOC C06_M01_090_010>[{i Dostya}]: The Saucer has destroyed the Control Center. Return to the Nation. We must prepare for the Aeon attack.', vid = 'C06_Dostya_M01_00569.sfd', bank = 'C06_VO', cue = 'C06_Dostya_M01_00569', faction = 'Cybran'},
}

-- The mission completes
C06_M01_100 = {
  {text = '<LOC C06_M01_100_010>[{i Ops}]: YES! The Aeon saucer is down!', vid = 'C06_Ops_M01_00570.sfd', bank = 'C06_VO', cue = 'C06_Ops_M01_00570', faction = 'Cybran'},
}

-- If Arnold is still alive when mission is completed
C06_M01_110 = {
  {text = '<LOC C06_M01_110_010>[{i Arnold}]: That changes nothing. Our victory was determined long ago.', vid = 'C06_Arnold_M01_00571.sfd', bank = 'C06_VO', cue = 'C06_Arnold_M01_00571', faction = 'Aeon'},
}

--------------------------------
-- Opnode ID: M01_OBJ
-- Into the Fire Objectives
--------------------------------

-- Primary Objectives
OpC06_M1P1_Title = '<LOC C06_M01_OBJ_010_111>Destroy the CZAR'

-- Primary Objectives
OpC06_M1P1_Desc = '<LOC C06_M01_OBJ_010_112>The best option is to destroy the CZAR before it takes off. If it does manage to launch, there is a limited window of time to take it down before it reaches Black Sun. Do not let it attack Black Sun\'s Control Center.'

-- Secondary Objectives
OpR6_Bonus1_Title = '<LOC C06_M01_OBJ_020_111>Spider Swarm'

-- Secondary Objectives
OpR6_Bonus1_Desc = '<LOC C06_M01_OBJ_020_112>You built over %s Spiderbots.'

-- Secondary Objectives
OpR6_Bonus2_Title = '<LOC C06_M01_OBJ_020_121>Firefight'

-- Secondary Objectives
OpR6_Bonus2_Desc = '<LOC C06_M01_OBJ_020_122>You defeated over %s enemy units.'

-- Secondary Objectives
OpC06_M1S1_Title = '<LOC C06_M01_OBJ_030_111>Eliminate the Aeon Commander'

-- Secondary Objectives
OpC06_M1S1_Desc = '<LOC C06_M01_OBJ_030_112>Commander Arnold is a threat to both you, and the success of the operation. Eliminate him if the opportunity presents itself.'



--------------------------------
-- Opnode ID: M02
-- Allies
--------------------------------



-- PO# 1 & PO#2 revealed
C06_M02_010 = {
  {text = '<LOC C06_M02_010_010>[{i Dostya}]: So far so good, Commander. We will now upload QAI into your ACU. Ops will give you the details. Dostya out.', vid = 'C06_Dostya_M02_00572.sfd', bank = 'C06_VO', cue = 'C06_Dostya_M02_00572', faction = 'Cybran'},
  {text = '<LOC C06_M02_010_020>[{i Ops}]: Commander, because of the bandwidth demands, you need to build a Quantum Gate before we can upload the QAI into your ACU. The upload will take some time, so make sure the area around the Gate is secure. Ops out.', vid = 'C06_Ops_M02_01127.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_01127', faction = 'Cybran'},
}

-- 3 minutes after mission start
C06_M02_020 = {
  {text = '<LOC C06_M02_020_010>[{i Jericho}]: Commander, Black Sun is almost finished! They have to charge it before it can fire, but we\'re running out of time!', vid = 'C06_Jericho_M02_00573.sfd', bank = 'C06_VO', cue = 'C06_Jericho_M02_00573', faction = 'Cybran'},
}

-- If Jericho is Dead at 3 minutes after mission start
C06_M02_025 = {
  {text = '<LOC C06_M02_025_010>[{i Ops}]: Black Sun is nearly complete! They have to charge it before it can fire, but time is against us!', vid = 'C06_Ops_M02_01128.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_01128', faction = 'Cybran'},
}

-- 4 minutes after mission start
C06_M02_030 = {
  {text = '<LOC C06_M02_030_010>[{i Ops}]: Sensors are indicating that UEF forces are moving north and establishing a defensive line. You must break through their position in order to reach the Control Center. Ops out.', vid = 'C06_Ops_M02_00574.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00574', faction = 'Cybran'},
}

-- If the Quantum Gate is destroyed
C06_M02_040 = {
  {text = '<LOC C06_M02_040_010>[{i Ops}]: The Quantum Gate was destroyed! You have to build another one before we can upload QAI! Ops out.', vid = 'C06_Ops_M02_00575.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00575', faction = 'Cybran'},
}

-- When the Quantum Gate is finished. PO#1 completed
C06_M02_050 = {
  {text = '<LOC C06_M02_050_010>[{i Ops}]: Okay, Commander, move your ACU next to the Gate. The upload will begin automatically. Do not move away from the Gate until you are notified that the upload is complete. Ops out.', vid = 'C06_Ops_M02_00576.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00576', faction = 'Cybran'},
}

-- When the download starts
C06_M02_060 = {
  {text = '<LOC C06_M02_060_010>[{i Ops}]: The upload has started, Commander. The Gate must survive, otherwise the upload will have to start again. Defend your position! Ops out.', vid = 'C06_Ops_M02_00577.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00577', faction = 'Cybran'},
}

-- If the download is interrupted
C06_M02_070 = {
  {text = '<LOC C06_M02_070_010>[{i Ops}]: Sir, the upload was interrupted! Move your ACU back to the Gate to restart it. Ops out.', vid = 'C06_Ops_M02_00578.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00578', faction = 'Cybran'},
}

-- Download complete, Aiko request reinforcements, prelude to Phase 3.
C06_M02_080 = {
  {text = '<LOC C06_M02_080_010>[{i Aiko}]: This is Major Aiko. Black Sun is under heavy attack by Cybran and Aeon forces. Requesting assistance. I repeat, Black Sun is under attack. We need all the help we can get! Aiko out.', vid = 'C06_Aiko_M02_00579.sfd', bank = 'C06_VO', cue = 'C06_Aiko_M02_00579', faction = 'UEF'},
}

-- Download complete. PO#2 finished
C06_M02_090 = {
  {text = '<LOC C06_M02_090_010>[{i QAI}]: I have been successfully uploaded into the memory of your ACU, Commander. Your next task is to deliver me to the Black Sun Control Center so that I may integrate with its systems. QAI out.', vid = 'C06_QAI_M02_00580.sfd', bank = 'C06_VO', cue = 'C06_QAI_M02_00580', faction = 'Cybran'},
}

-- When the UEF assaults begin
C06_M02_100 = {
  {text = '<LOC C06_M02_100_010>[{i Ops}]: Incoming UEF forces! Ops out.', vid = 'C06_Ops_M02_00581.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00581', faction = 'Cybran'},
}

-- When the Aeon assaults begin
C06_M02_110 = {
  {text = '<LOC C06_M02_110_010>[{i Ops}]: Aeon forces are vectoring towards your base! Get ready! Ops out.', vid = 'C06_Ops_M02_00582.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00582', faction = 'Cybran'},
}

-- Mission ends when all PO#3 is completed
C06_M02_130 = {
  {text = '<LOC C06_M02_130_010>[{i QAI}]: My integration into the Black Sun Control Center is complete. I will now attempt to take control of Black Sun itself. QAI out.', vid = 'C06_QAI_M02_00583.sfd', bank = 'C06_VO', cue = 'C06_QAI_M02_00583', faction = 'Cybran'},
  {text = '<LOC C06_M02_130_020>[{i Ops}]: You did it! Once QAI finishes its integration, you can fire Black Sun. Ops out.', vid = 'C06_Ops_M02_00584.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00584', faction = 'Cybran'},
}

-- Objective Reminders for PO1, #1
C06_M02_150 = {
  {text = '<LOC C06_M02_150_010>[{i Ops}]: We need that Gate built so we can upload the QAI, sir. Ops out. ', vid = 'C06_Ops_M02_00585.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00585', faction = 'Cybran'},
}

-- Objective Reminders for PO1, #2
C06_M02_155 = {
  {text = '<LOC C06_M02_155_010>[{i Ops}]: Where\'s the Gate? We\'re running out of time. Ops out.', vid = 'C06_Ops_M02_01526.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_01526', faction = 'Cybran'},
}

-- Objective Reminders for PO2, #1
C06_M02_160 = {
  {text = '<LOC C06_M02_160_010>[{i Ops}]: Move your ACU next to the Gate to start the download, Commander. Ops out. ', vid = 'C06_Ops_M02_00587.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00587', faction = 'Cybran'},
}

-- Objective Reminders for PO2, #2
C06_M02_165 = {
  {text = '<LOC C06_M02_165_010>[{i Ops}]: Sir, we need to start the upload! Move your ACU next to the Gate and we\'ll start immediately. Ops out. ', vid = 'C06_Ops_M02_01527.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_01527', faction = 'Cybran'},
}

-- Objective Reminders for PO3, #1
C06_M02_170 = {
  {text = '<LOC C06_M02_170_010>[{i Ops}]: You must capture the Control Center and get QAI downloaded ASAP! Ops out. ', vid = 'C06_Ops_M02_00589.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00589', faction = 'Cybran'},
}

-- Objective Reminders for PO3, #2
C06_M02_175 = {
  {text = '<LOC C06_M02_175_010>[{i Ops}]: Sir, we need to start the upload! Move your ACU next to the Gate and we\'ll start immediately. Ops out. ', vid = 'C06_Ops_M02_01528.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_01528', faction = 'Cybran'},
}

--------------------------------
-- Opnode ID: M02_OBJ
-- Allies Objectives
--------------------------------

-- Primary Objectives
OpC06_M2P1_Title = '<LOC C06_M02_OBJ_010_211>Build a Quantum Gate'

-- Primary Objectives
OpC06_M2P1_Desc = '<LOC C06_M02_OBJ_010_212>A Quantum Gate is required so that QAI can be uploaded into your ACU. The Gate should be built at a secure location, as it will take some time for you to fully download QAI.'

-- Primary Objectives
OpC06_M2P2_Title = '<LOC C06_M02_OBJ_010_221>Download the Quantum Virus'

-- Primary Objectives
OpC06_M2P2_Desc = '<LOC C06_M02_OBJ_010_222>Move your ACU next to your Quantum Gate to initiate the download of the Quantum Virus. The ACU must remain near the Gate for a short period of time for the download to finish.'

-- Primary Objectives
OpC06_M2P3_Title = '<LOC C06_M02_OBJ_010_231>Capture Black Sun Control Center'

-- Primary Objectives
OpC06_M2P3_Desc = '<LOC C06_M02_OBJ_010_232>The QAI must integrate itself with the Control Center\'s systems. This will enable it to reprogram Black Sun to distribute the Quantum Virus and the Symbiont Release Matrix upon firing.'

-- Secondary Objectives
OpC06_M2S1_Title = '<LOC C06_M02_OBJ_010_241>The Star Wars Project'

-- Secondary Objectives
OpC06_M2S1_Desc = '<LOC C06_M02_OBJ_010_242>The gloves are coming off. Both Aeon and UEF forces will resort to extreme measures to secure victory for themselves, including Strategic Missiles. Construct at least %s Guardian SMDs (in close proximity) to prepare for a potential Nuclear strike once you\'ve captured the Control Center.'




--------------------------------
-- Opnode ID: M03
-- Call of Freedom
--------------------------------



-- PO#1 & PO#2 revealed
C06_M03_010 = {
  {text = '<LOC C06_M03_010_010>[{i QAI}]: They have disconnected Black Sun from the Control Center. I am unable to establish control of the weapon.', vid = 'C06_QAI_M03_00591.sfd', bank = 'C06_VO', cue = 'C06_QAI_M03_00591', faction = 'Cybran'},
  {text = '<LOC C06_M03_010_020>[{i Dostya}]: Commander, new orders! You must capture Black Sun so QAI can complete its integration! Move quickly! ', vid = 'C06_Dostya_M03_00592.sfd', bank = 'C06_VO', cue = 'C06_Dostya_M03_00592', faction = 'Cybran'},
}

-- If the Atlantis surfaces
C06_M03_030 = {
  {text = '<LOC C06_M03_030_010>[{i Aiko}]: I will not let you have Black Sun!', vid = 'C06_Aiko_M03_00594.sfd', bank = 'C06_VO', cue = 'C06_Aiko_M03_00594', faction = 'UEF'},
  {text = '<LOC C06_M03_030_020>[{i Clarke}]: This is General Clarke! Stop them!', vid = 'C06_Clarke_M03_00595.sfd', bank = 'C06_VO', cue = 'C06_Clarke_M03_00595', faction = 'UEF'},
  {text = '<LOC C06_M02_100_010>[{i Ops}]: Incoming UEF forces! Ops out.', vid = 'C06_Ops_M02_00581.sfd', bank = 'C06_VO', cue = 'C06_Ops_M02_00581', faction = 'Cybran'},
}

-- If Aiko is killed
C06_M03_050 = {
  {text = '<LOC C06_M03_050_010>[{i Aiko}]: Aaaaaaaaagh! ', vid = 'C06_Aiko_M03_00596.sfd', bank = 'C06_VO', cue = 'C06_Aiko_M03_00596', faction = 'UEF'},
}

-- If Arnold is killed
C06_M03_055 = {
  {text = '<LOC C06_M03_055_010>[{i Arnold}]: Princess!', vid = 'C06_Arnold_M03_01106.sfd', bank = 'C06_VO', cue = 'C06_Arnold_M03_01106', faction = 'Aeon'},
}

-- If Blake is killed
C06_M03_100 = {
  {text = '<LOC A05_M02_110_010>[{i Blake}]: Aaaaargh', vid = 'A05_Blake_M02_00998.sfd', bank = 'A05_VO', cue = 'A05_Blake_M02_00998', faction = 'UEF'},
}

-- When Black Sun is captured. PO#1 completed
C06_M03_060 = {
  {text = '<LOC C06_M03_060_010>[{i QAI}]: I have successfully re-established the connection between the Control Center and Black Sun. The weapon is ready to fire.', vid = 'C06_QAI_M03_00597.sfd', bank = 'C06_VO', cue = 'C06_QAI_M03_00597', faction = 'Cybran'},
  {text = '<LOC C06_M03_060_020>[{i Dostya}]: Do it! Fire!', vid = 'C06_Dostya_M03_00598.sfd', bank = 'C06_VO', cue = 'C06_Dostya_M03_00598', faction = 'Cybran'},
}

-- Objective Reminders for PO1, #1
C06_M03_070 = {
  {text = '<LOC C06_M03_070_010>[{i Ops}]: All that stands between us and victory is you capturing Black Sun, sir. Ops out. ', vid = 'C06_Ops_M03_00599.sfd', bank = 'C06_VO', cue = 'C06_Ops_M03_00599', faction = 'Cybran'},
}

-- Objective Reminders for PO1, #2
C06_M03_075 = {
  {text = '<LOC C06_M03_075_010>[{i Ops}]: You need to capture Black Sun, sir! QAI still needs to reconfigure it! Ops out.', vid = 'C06_Ops_M03_01529.sfd', bank = 'C06_VO', cue = 'C06_Ops_M03_01529', faction = 'Cybran'},
}

-- Objective Reminders for PO2, #1
C06_M03_080 = {
  {text = '<LOC C06_M03_080_010>[{i Ops}]: Fire Black Sun! Fire it now! ', vid = 'C06_Ops_M03_00601.sfd', bank = 'C06_VO', cue = 'C06_Ops_M03_00601', faction = 'Cybran'},
}

-- Objective Reminders for PO2, #2
C06_M03_085 = {
  {text = '<LOC C06_M03_085_010>[{i Ops}]: We\'re so close! Just fire Black Sun and we\'ll win!', vid = 'C06_Ops_M03_01530.sfd', bank = 'C06_VO', cue = 'C06_Ops_M03_01530', faction = 'Cybran'},
}

-- If Black Sun is destroyed.
C06_M03_090 = {
  {text = '<LOC C06_M03_090_010>[{i Dostya}]: Black Sun has been destroyed. Return to the Nation. We must prepare for the Aeon attack.', vid = 'C06_Dostya_M03_00603.sfd', bank = 'C06_VO', cue = 'C06_Dostya_M03_00603', faction = 'Cybran'},
}

--------------------------------
-- Opnode ID: M03_OBJ
-- Call of Freedom Objectives
--------------------------------

-- Primary Objective
OpC06_M3P1_Title = '<LOC C06_M03_OBJ_010_311>Capture Black Sun'

-- Primary Objective
OpC06_M3P1_Desc = '<LOC C06_M03_OBJ_010_312>The UEF has cut off Black Sun from the Control Center in an effort to stop QAI from taking it over. You must capture Black Sun and re-establish the connection so QAI can finish reprogramming the weapon.'

-- Primary Objective
OpC06_M3P2_Title = '<LOC C06_M03_OBJ_010_321>Fire Black Sun'

-- Primary Objective
OpC06_M3P2_Desc = '<LOC C06_M03_OBJ_010_322>Select Black Sun and click the Fire button. End the Infinite War!'



--------------------------------
-- Opnode ID: T01
-- Enemey taunt
--------------------------------



-- Taunt1 ( Aiko )
TAUNT1 = {
  {text = '<LOC C06_T01_010_010>[{i Aiko}]: The UEF will finally end the Infinite War!', vid = 'C06_Aiko_T01_00543.sfd', bank = 'C06_VO', cue = 'C06_Aiko_T01_00543', faction = 'UEF'},
}

-- Taunt2
TAUNT2 = {
  {text = '<LOC C06_T01_020_010>[{i Aiko}]: I have the might of the UEF behind me!', vid = 'C06_Aiko_T01_00544.sfd', bank = 'C06_VO', cue = 'C06_Aiko_T01_00544', faction = 'UEF'},
}

-- Taunt3
TAUNT3 = {
  {text = '<LOC C06_T01_030_010>[{i Aiko}]: I will defend this Facility with my life!', vid = 'C06_Aiko_T01_00545.sfd', bank = 'C06_VO', cue = 'C06_Aiko_T01_00545', faction = 'UEF'},
}

-- Taunt4
TAUNT4 = {
  {text = '<LOC C06_T01_040_010>[{i Aiko}]: Black Sun will destroy you and every other madman.', vid = 'C06_Aiko_T01_00546.sfd', bank = 'C06_VO', cue = 'C06_Aiko_T01_00546', faction = 'UEF'},
}

-- Taunt5
TAUNT5 = {
  {text = '<LOC C06_T01_050_010>[{i Aiko}]: This island shall be your tomb.', vid = 'C06_Aiko_T01_00547.sfd', bank = 'C06_VO', cue = 'C06_Aiko_T01_00547', faction = 'UEF'},
}

-- Taunt6
TAUNT6 = {
  {text = '<LOC C06_T01_060_010>[{i Aiko}]: The UEF will triumph!', vid = 'C06_Aiko_T01_00548.sfd', bank = 'C06_VO', cue = 'C06_Aiko_T01_00548', faction = 'UEF'},
}

-- Taunt7
TAUNT7 = {
  {text = '<LOC C06_T01_070_010>[{i Aiko}]: There is no chance of surrender. This is a fight to the end.', vid = 'C06_Aiko_T01_00549.sfd', bank = 'C06_VO', cue = 'C06_Aiko_T01_00549', faction = 'UEF'},
}

-- Taunt8 ( Aiko)
TAUNT8 = {
  {text = '<LOC C06_T01_080_010>[{i Aiko}]: The UEF will unite the galaxy...no matter the cost.', vid = 'C06_Aiko_T01_00550.sfd', bank = 'C06_VO', cue = 'C06_Aiko_T01_00550', faction = 'UEF'},
}

-- Taunt9 ( Arnold )
TAUNT9 = {
  {text = '<LOC C06_T01_090_010>[{i Arnold}]: There is no stopping the Aeon.', vid = 'C06_Arnold_T01_00551.sfd', bank = 'C06_VO', cue = 'C06_Arnold_T01_00551', faction = 'Aeon'},
}

-- Taunt10
TAUNT10 = {
  {text = '<LOC C06_T01_100_010>[{i Arnold}]: Once the UEF falls, the Cybrans are next.', vid = 'C06_Arnold_T01_00552.sfd', bank = 'C06_VO', cue = 'C06_Arnold_T01_00552', faction = 'Aeon'},
}

-- Taunt11
TAUNT11 = {
  {text = '<LOC C06_T01_110_010>[{i Arnold}]: You are an abomination.', vid = 'C06_Arnold_T01_00553.sfd', bank = 'C06_VO', cue = 'C06_Arnold_T01_00553', faction = 'Aeon'},
}

-- Taunt12
TAUNT12 = {
  {text = '<LOC C06_T01_120_010>[{i Arnold}]: The UEF will never fire that weapon.', vid = 'C06_Arnold_T01_00554.sfd', bank = 'C06_VO', cue = 'C06_Arnold_T01_00554', faction = 'Aeon'},
}

-- Taunt13
TAUNT13 = {
  {text = '<LOC C06_T01_130_010>[{i Arnold}]: I will exterminate the Cybrans myself.', vid = 'C06_Arnold_T01_00555.sfd', bank = 'C06_VO', cue = 'C06_Arnold_T01_00555', faction = 'Aeon'},
}

-- Taunt14
TAUNT14 = {
  {text = '<LOC C06_T01_140_010>[{i Arnold}]: The Avatar-of-War demands Earth be cleansed.', vid = 'C06_Arnold_T01_00556.sfd', bank = 'C06_VO', cue = 'C06_Arnold_T01_00556', faction = 'Aeon'},
}

-- Taunt15
TAUNT15 = {
  {text = '<LOC C06_T01_150_010>[{i Arnold}]: Earth is ours!', vid = 'C06_Arnold_T01_00557.sfd', bank = 'C06_VO', cue = 'C06_Arnold_T01_00557', faction = 'Aeon'},
}

-- Taunt16 ( Arnold )
TAUNT16 = {
  {text = '<LOC C06_T01_160_010>[{i Arnold}]: You will soon be extinct.', vid = 'C06_Arnold_T01_00558.sfd', bank = 'C06_VO', cue = 'C06_Arnold_T01_00558', faction = 'Aeon'},
}

-- Taunt 17 ( Blake )
TAUNT17 = {
  {text = '<LOC A05_T01_100_010>[{i Blake}]: The UEF will never stop waging war against the Aeon.', vid = 'A05_Blake_T01_00947.sfd', bank = 'A05_VO', cue = 'A05_Blake_T01_00947', faction = 'UEF'},
}

-- Taunt 18
TAUNT18 = {
  {text = '<LOC A05_T01_110_010>[{i Blake}]: Vengeance will be mine!', vid = 'A05_Blake_T01_00948.sfd', bank = 'A05_VO', cue = 'A05_Blake_T01_00948', faction = 'UEF'},
}

-- Taunt 19
TAUNT19 = {
  {text = '<LOC A05_T01_130_010>[{i Blake}]: You abandoned your humanity a long time ago.', vid = 'A05_Blake_T01_00950.sfd', bank = 'A05_VO', cue = 'A05_Blake_T01_00950', faction = 'UEF'},
}

-- Taunt 20
TAUNT20 = {
  {text = '<LOC A05_T01_140_010>[{i Blake}]: Soon the Aeon will be extinct.', vid = 'A05_Blake_T01_00951.sfd', bank = 'A05_VO', cue = 'A05_Blake_T01_00951', faction = 'UEF'},
}

-- Taunt 21
TAUNT21 = {
  {text = '<LOC A05_T01_150_010>[{i Blake}]: You will answer for your crimes!', vid = 'A05_Blake_T01_00952.sfd', bank = 'A05_VO', cue = 'A05_Blake_T01_00952', faction = 'UEF'},
}

-- Taunt 22 ( Blake )
TAUNT22 = {
  {text = '<LOC A05_T01_160_010>[{i Blake}]: I will not allow you to escape!', vid = 'A05_Blake_T01_00953.sfd', bank = 'A05_VO', cue = 'A05_Blake_T01_00953', faction = 'UEF'},
}
