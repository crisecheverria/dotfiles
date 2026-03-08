-- Swedish sentences from Rivstart A1+A2
-- Each entry: { sv = "Swedish sentence", en = "English translation" }
local M = {}

M.levels = {
  beginner = {
    name = "Nybörjare A1 (Beginner)",
    sentences = {
      -- Chapter 1: Presentation
      { sv = "Jag heter Patricia.", en = "My name is Patricia." },
      { sv = "Varifrån kommer du?", en = "Where do you come from?" },
      { sv = "Jag kommer från Argentina.", en = "I come from Argentina." },
      { sv = "Vad talar du för språk?", en = "What languages do you speak?" },
      { sv = "Jag talar engelska och lite svenska.", en = "I speak English and a little Swedish." },
      { sv = "Jag bor i Stockholm.", en = "I live in Stockholm." },
      { sv = "Vad heter du?", en = "What is your name?" },
      { sv = "Jag är från Sverige.", en = "I am from Sweden." },
      { sv = "Hur stavar du det?", en = "How do you spell that?" },
      { sv = "Är du gift?", en = "Are you married?" },
      { sv = "Jag är singel.", en = "I am single." },
      { sv = "Jag har två barn.", en = "I have two children." },
      { sv = "Min man heter Andreas.", en = "My husband's name is Andreas." },
      { sv = "Jag har en flickvän.", en = "I have a girlfriend." },
      -- Chapter 2: Greetings & introductions
      { sv = "Hur mår du?", en = "How are you?" },
      { sv = "Bara bra, tack!", en = "Just fine, thanks!" },
      { sv = "Helt okej.", en = "Totally okay." },
      { sv = "Det är lugnt.", en = "It's all good." },
      { sv = "Det är kanonbra!", en = "It's super great!" },
      { sv = "Vad gör du i Sverige?", en = "What do you do in Sweden?" },
      { sv = "Hon läser svenska.", en = "She studies Swedish." },
      { sv = "Han jobbar på ett spelföretag.", en = "He works at a gaming company." },
      { sv = "Trivs du i Sverige?", en = "Do you like it in Sweden?" },
      { sv = "Jag trivs bra i Sverige.", en = "I feel at home in Sweden." },
      { sv = "Det här är min flickvän Pernilla.", en = "This is my girlfriend Pernilla." },
      { sv = "Trevligt att träffas.", en = "Nice to meet you." },
      { sv = "Vi ses på kursen på måndag.", en = "See you at the course on Monday." },
      { sv = "Hej hej!", en = "Bye bye!" },
      { sv = "Vad har du i väskan?", en = "What do you have in the bag?" },
      -- Chapter 3: Numbers, time, address
      { sv = "Vilken gata bor du på?", en = "What street do you live on?" },
      { sv = "Hur många barn har du?", en = "How many children do you have?" },
      { sv = "Vad har du för telefonnummer?", en = "What is your phone number?" },
      { sv = "Hur gammal är du?", en = "How old are you?" },
      { sv = "Hur mycket är klockan?", en = "What time is it?" },
      { sv = "Hon är halv sju.", en = "It's half past six." },
      { sv = "Den är fem över sju.", en = "It's five past seven." },
      { sv = "Vilken tid börjar vi?", en = "What time do we start?" },
      { sv = "Klockan nio.", en = "At nine o'clock." },
      { sv = "Okej, tack. Vi ses imorgon!", en = "Okay, thanks. See you tomorrow!" },
      -- Chapter 4: Shopping & food
      { sv = "Jag ska gå till närbutiken.", en = "I'm going to the convenience store." },
      { sv = "Jag måste köpa ett kontantkort.", en = "I must buy a prepaid card." },
      { sv = "En falafelmeny, tack.", en = "A falafel meal, please." },
      { sv = "Vad vill du dricka?", en = "What do you want to drink?" },
      { sv = "En mellanläsk, tack.", en = "A medium soda, please." },
      { sv = "En latte, tack.", en = "A latte, please." },
      { sv = "Det blir 82, tack.", en = "That will be 82, please." },
      { sv = "Vad kostar det?", en = "How much does it cost?" },
      { sv = "Vad ska du äta ikväll?", en = "What are you going to eat tonight?" },
      { sv = "Jag vill laga pizza.", en = "I want to make pizza." },
    },
  },
  elementary = {
    name = "Grundläggande A1-A2 (Elementary)",
    sentences = {
      -- Chapter 5: Free time
      { sv = "Vill du se Valkyrian på Operan nästa vecka?", en = "Do you want to see Valkyria at the Opera next week?" },
      { sv = "Tyvärr, jag kan inte.", en = "Unfortunately, I can't." },
      { sv = "Jaha. Vad synd!", en = "I see. What a pity!" },
      { sv = "Kicki och jag ska gå på bio på lördag.", en = "Kicki and I are going to the cinema on Saturday." },
      { sv = "Vill du hänga med?", en = "Do you want to come along?" },
      { sv = "Ja, vad kul!", en = "Yes, how fun!" },
      { sv = "Har du lust att gå på hockey med mig?", en = "Do you feel like going to hockey with me?" },
      { sv = "Ja, gärna.", en = "Yes, I'd love to." },
      { sv = "Jag ska träffa Peter på tisdag.", en = "I'm going to meet Peter on Tuesday." },
      { sv = "Jag brukar träffa vänner.", en = "I usually meet friends." },
      { sv = "Jag älskar klassisk musik!", en = "I love classical music!" },
      { sv = "Jag tycker om att fiska.", en = "I like to fish." },
      { sv = "Jag gillar att laga mat.", en = "I like to cook." },
      { sv = "Jag går aldrig på bio.", en = "I never go to the cinema." },
      { sv = "Ibland går jag på bio.", en = "Sometimes I go to the cinema." },
      { sv = "Jag går sällan på konsert.", en = "I seldom go to concerts." },
      -- Chapter 6: Family & past
      { sv = "Vad gjorde du i lördags?", en = "What did you do last Saturday?" },
      { sv = "Jag var på Stadshuset på fest.", en = "I was at the City Hall at a party." },
      { sv = "Min faster fick Nobelpriset.", en = "My aunt won the Nobel Prize." },
      { sv = "Vad heter din pappa?", en = "What is your father's name?" },
      { sv = "Min pappa heter Wolfgang.", en = "My father's name is Wolfgang." },
      { sv = "Sofie, vad heter din bror?", en = "Sofie, what is your brother's name?" },
      { sv = "Bor dina systrar också i Sverige?", en = "Do your sisters also live in Sweden?" },
      { sv = "Mitt barnbarn heter Oscar.", en = "My grandchild is called Oscar." },
      -- Chapter 7: Shopping & clothes
      { sv = "Jag skulle vilja prova de här röda byxorna.", en = "I would like to try on these red pants." },
      { sv = "Vilken storlek har du?", en = "What size are you?" },
      { sv = "De är lite för stora.", en = "They are a little too big." },
      { sv = "Hur mycket kostar den?", en = "How much does it cost?" },
      { sv = "Jag tar den.", en = "I'll take it." },
      { sv = "Har ni något billigare?", en = "Do you have anything cheaper?" },
      { sv = "Jag shoppar sällan.", en = "I rarely shop." },
      { sv = "Jag älskar att shoppa!", en = "I love to shop!" },
    },
  },
  intermediate = {
    name = "Medelnivå A2 (Intermediate)",
    sentences = {
      -- Chapter 8: Travel & weather
      { sv = "Har du varit i Sverige förut?", en = "Have you been to Sweden before?" },
      { sv = "Jag har aldrig rest till Norrland.", en = "I have never traveled to Norrland." },
      { sv = "Vädret i Sverige är ganska varierat.", en = "The weather in Sweden is quite varied." },
      { sv = "Det regnar ofta på hösten.", en = "It often rains in autumn." },
      { sv = "Sommaren kan vara varm och solig.", en = "The summer can be warm and sunny." },
      { sv = "Vintern kan vara kall och snöig.", en = "The winter can be cold and snowy." },
      -- Chapter 9: Directions & transport
      { sv = "Hur kommer jag till stationen?", en = "How do I get to the station?" },
      { sv = "Gå rakt fram och ta till höger.", en = "Go straight ahead and turn right." },
      { sv = "Det ligger på höger sida.", en = "It's on the right side." },
      { sv = "Jag ska åka buss till jobbet.", en = "I'm going to take the bus to work." },
      -- Chapter 10-12: Daily life, restaurant
      { sv = "Jag skulle vilja beställa mat.", en = "I would like to order food." },
      { sv = "Kan jag få notan, tack?", en = "Can I have the bill, please?" },
      { sv = "Maten var mycket god.", en = "The food was very good." },
      { sv = "Jag behöver köpa nya kläder.", en = "I need to buy new clothes." },
      { sv = "Vilken tid öppnar affären?", en = "What time does the store open?" },
      { sv = "Han tycker om att läsa böcker.", en = "He likes to read books." },
      { sv = "Jag ska resa till Norge nästa vecka.", en = "I will travel to Norway next week." },
      { sv = "Det finns många sjöar i Sverige.", en = "There are many lakes in Sweden." },
      { sv = "Barnen leker i parken.", en = "The children play in the park." },
      { sv = "Jag brukar springa varje morgon.", en = "I usually run every morning." },
      { sv = "Vi träffas på fredag kväll.", en = "We meet on Friday evening." },
      { sv = "Jag har bott här i tre år.", en = "I have lived here for three years." },
      { sv = "Hon arbetar på ett sjukhus.", en = "She works at a hospital." },
      { sv = "Kan du rekommendera en bra restaurang?", en = "Can you recommend a good restaurant?" },
      { sv = "Det var trevligt att träffa dig.", en = "It was nice to meet you." },
      { sv = "Jag gillar att laga mat hemma.", en = "I like to cook at home." },
      -- Chapter 13-14: Work & invitations
      { sv = "Vad jobbar du med?", en = "What do you work with?" },
      { sv = "Jag söker jobb som ingenjör.", en = "I'm looking for a job as an engineer." },
      { sv = "Kan du skriva en kort text om dig själv?", en = "Can you write a short text about yourself?" },
      { sv = "Välkommen till festen!", en = "Welcome to the party!" },
      -- Chapter 15: Sweden & Swedish culture
      { sv = "Svenskarna verkar gilla siffror.", en = "Swedes seem to like numbers." },
      { sv = "I Sverige pratar alla om vädret hela tiden.", en = "In Sweden everyone talks about the weather all the time." },
      { sv = "På vintern längtar alla efter våren och sommaren.", en = "In winter everyone longs for spring and summer." },
      -- Chapter 16: Education
      { sv = "Vad tyckte du om skolan?", en = "What did you think about school?" },
      { sv = "Mina favoritämnen var matte och engelska.", en = "My favorite subjects were math and English." },
      { sv = "Jag gick naturvetenskapliga programmet.", en = "I studied the natural sciences program." },
      { sv = "Jag ska fortsätta studera svenska.", en = "I will continue to study Swedish." },
      { sv = "Jag är färdig med min examen om två år.", en = "I will finish my degree in two years." },
    },
  },
  advanced = {
    name = "Avancerad A2+ (Advanced)",
    sentences = {
      -- Chapter 17: Housing
      { sv = "Titta på det här huset, tre sovrum och stor trädgård.", en = "Look at this house, three bedrooms and a big garden." },
      { sv = "Det var dyrt.", en = "It was expensive." },
      { sv = "Jag tror att det är bättre att bo i stan.", en = "I think it's better to live in the city." },
      { sv = "Vi kanske ska titta på en mindre lägenhet.", en = "Maybe we should look at a smaller apartment." },
      { sv = "Det är roligare att bo i kollektiv än att bo ensam.", en = "It's more fun to live in a collective than to live alone." },
      -- Chapter 18: Conversations & technology
      { sv = "Du, vad är det här för något?", en = "Hey, what is this thing?" },
      { sv = "Det är vår nya kaffeapparat.", en = "It's our new coffee machine." },
      { sv = "Hur var din helg då?", en = "So how was your weekend?" },
      { sv = "Vi åkte ut till landet och krattade löv.", en = "We went out to the countryside and raked leaves." },
      { sv = "Ska inte din dotter flytta hemifrån snart?", en = "Isn't your daughter going to move out soon?" },
      -- Chapter 19: Health
      { sv = "Hur kan jag hjälpa dig?", en = "How can I help you?" },
      { sv = "Jag har ont i huvudet.", en = "I have a headache." },
      { sv = "Hur länge har du haft huvudvärk?", en = "How long have you had a headache?" },
      { sv = "Jag har haft ont i huvudet i flera månader.", en = "I have had a headache for several months." },
      { sv = "Tar du någon medicin?", en = "Do you take any medicine?" },
      { sv = "Jag brukar ta huvudvärkstabletter.", en = "I usually take headache pills." },
      -- Chapter 20: News & society
      { sv = "Trots det dåliga vädret bestämde vi oss för att vandra.", en = "Despite the bad weather we decided to hike." },
      { sv = "Det svenska samhället bygger på jämlikhet och rättvisa.", en = "Swedish society is built on equality and justice." },
      { sv = "Midsommar är en av de viktigaste högtiderna i Sverige.", en = "Midsummer is one of the most important holidays in Sweden." },
      { sv = "Ju mer man övar, desto bättre blir man.", en = "The more you practice, the better you become." },
      { sv = "Det är viktigt att ta hand om miljön.", en = "It is important to take care of the environment." },
      { sv = "Alla har rätt till sin egen åsikt.", en = "Everyone has the right to their own opinion." },
      { sv = "Att lära sig ett nytt språk kräver tålamod.", en = "Learning a new language requires patience." },
      { sv = "Fika är en viktig del av den svenska kulturen.", en = "Fika is an important part of Swedish culture." },
      { sv = "Forskningen visar att motion förbättrar hälsan.", en = "Research shows that exercise improves health." },
      { sv = "Man lär sig något av allt man gör.", en = "You learn something from everything you do." },
      { sv = "Svenskar dricker i genomsnitt tre till fyra koppar kaffe per dag.", en = "Swedes drink on average three to four cups of coffee per day." },
      { sv = "Det är inte alltid lätt att välja hur man ska bo.", en = "It's not always easy to choose how to live." },
    },
  },
}

function M.get_all_sentences()
  local all = {}
  for _, level in pairs(M.levels) do
    for _, sentence in ipairs(level.sentences) do
      table.insert(all, sentence)
    end
  end
  return all
end

function M.get_level_sentences(level)
  local lvl = M.levels[level]
  if lvl then
    return lvl.sentences
  end
  return {}
end

function M.get_level_list()
  local order = { "beginner", "elementary", "intermediate", "advanced" }
  local list = {}
  for _, key in ipairs(order) do
    local lvl = M.levels[key]
    if lvl then
      table.insert(list, { key = key, name = lvl.name, count = #lvl.sentences })
    end
  end
  return list
end

return M
