require 'active_record'
require './lib/answer'
require './lib/choice'
require './lib/question'
require './lib/response'
require './lib/survey'
require './lib/taker'

database_configurations = YAML::load(File.open("./db/config.yml"))
development_configuration = database_configurations["development"]
ActiveRecord::Base.establish_connection(development_configuration)

def welcome
  system "clear"
  puts "Welcome to the survey program!"
  puts "
WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWP'dP'dWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
WWWWWW'VWWWb &'''.o.. .dWWWWWWWWWWWWP~~''_{WWWWWWWWWWWWWWWWWWWWWW
WWWWWWb  '''''''w.     jWWWWWWWP'  ,.--''    .wWWWWWWWWWWWWWWWWWW
WWWWWWWbWWWWF''''''    WWWWWWP' .-'          {WWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWLLWP      jWWWWP'               .wwWWWWWWWWW WWWWWWWW
WWWWW'W'W'WWWW'      jWWW'                 {WWWWWWWWWWP  'VWWWWWW
WWWWWW, dWWWW'      jWWWW                 .wwWWP'.w.'WWP.WWWWWWWW
WWWWWW' VWWWW        VWW'               _{WWWW( WWWW. P.WWWWWWWWW
::::::':  :::         '                {  ':::::. '' ,.::::::::::
:::::,:::  ::                                '''''  .::::::::::::
::::::::::                                       ..,:::::::::::::
:::::::::::   .                  ..:.      ':::::::::::::::::::::
:::::::::::: ::   .: ::::::::   :::::::.          '::::::::::::::
::::::::::::::' .::::::::::::.    .::::::::::::::  ::::::::::::::
:::::::::::::'.:::::::::::::::::  ::::::::::::::'  ::::::::::::::
:::::::'.....:.. ::::::::'......:. :::::::::'....::.'::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  "
  main_menu
end

def main_menu
  choice = nil
  until choice == 'X'
    puts "press 'D' for design menu"
    puts "press 'T' for taker menu"
    puts "press 'X' to exit the program"

    choice = gets.chomp.upcase
    case choice
    when 'D'
      design_menu
    when 'T'
      create_taker
    when 'X'
      puts "Thanks for using SurveyMakerPro 60000"
    else
      puts "Invalid input"
    end
  end
end

def design_menu
  choice = nil
  until choice == 'M'
    puts "Press 'S' to create a new survey"
    puts "Press 'VS' to view all surveys"
    puts "Press 'Q' to create and add a question to a survey"
    puts "Press 'VQ' to view all the questions in a particular survey"
    puts "Press 'A' to view analytics for a survey"
    puts "Press 'M' to return to the main menu"

    choice = gets.chomp.upcase
    case choice
    when 'S'
      create_survey
    when 'VS'
      view_surveys
    when 'Q'
      create_question
    when 'VQ'
      view_questions
    when 'A'
      view_analytics
    when 'M'
      puts "Returning to main menu..."
    else
      puts "Invalid input"
    end
  end
end

def create_survey
  puts "Name your survey:"
  name = gets.chomp
  survey = Survey.new({name: name})
  if survey.save
    puts "#{survey.name} ADDED!"
  else
    puts "Invalid survey:"
    survey.errors.full_messages.each { |message| puts message }
  end
end

def view_surveys
  puts "Available surveys:"
  Survey.all.each_with_index do |survey, index|
    puts "#{index + 1}. #{survey.name}"
  end
end

def create_question
  puts "Which survey would you like to add a question to?"
  view_surveys
  survey_index = gets.chomp.to_i
  survey = Survey.all[survey_index-1]
  puts "Enter the question:"
  description = gets.chomp
  puts "What type of question is it?"
  puts "1. Multiple Choice"
  puts "2. Multiple Answer"
  puts "3. Open-Ended"
  question_type = gets.chomp
  new_question = Question.create({description: description, question_type: question_type, survey_id: survey.id})
  if question_type == '3'
    puts "The question has been added to #{survey.name}"
  elsif question_type == '1' || question_type == '2'
    puts "Would you like to add answer choices to your question? (Y/N)"
    case gets.chomp.upcase
    when 'Y', 'YES'
      add_choices(new_question)
    end
    puts "The question has been added to #{survey.name}"
  else
    puts "Invalid selection"
  end
end

def view_questions
  puts "Which survey's questions would you like to view?"
  view_surveys
  survey_index = gets.chomp.to_i
  survey = Survey.all[survey_index-1]
  Question.where(survey_id: survey.id).each do |question|
    puts "\n #{question.description}"
    question.choices.each_with_index do |choice, index|
      puts "#{index + 1}. #{choice.description}"
    end
  end
end

def add_choices(question)
  selection = nil
  until selection == 'N' || selection == 'NO'
    puts "Enter an answer choice:"
    description = gets.chomp
    choice = Choice.create({description: description, question_id: question.id})
    puts "Choice: '#{choice.description}' added to Question: '#{question.description}'"
    puts "Add another answer choice? (Y/N)"
    selection = gets.chomp.upcase
  end
end

def create_taker
  puts "What is your name?"
  name = gets.chomp
  taker = Taker.new({name: name})
  if taker.save
    puts "#{taker.name} ADDED!"
    puts "Welcome, #{taker.name}!"
    taker_menu
  else
    puts "Invalid taker:"
    taker.errors.full_messages.each { |message| puts message }
  end
end

def taker_menu
  selection = nil
  until selection == 'N' || selection == 'NO'
    view_surveys
    puts "Which survey would you like to take?"
    index = gets.chomp.to_i
    survey = Survey.all[index - 1]
    take_survey(survey, taker)
    puts "Take another survey? (Y/N)"
    selection = gets.chomp.upcase
  end
end

def take_survey(survey, taker)
  survey.questions.each do |question|
    puts "\n #{question.description}"
    if question.question_type == '1'
      multiple_choice_q(question, taker)
    elsif question.question_type == '2'
      multiple_answer_q(question, taker)
    elsif question.question_type == '3'
      open_ended_q(question, taker)
    end
  end
  show_completed_survey(survey, taker)
end

def multiple_choice_q(question, taker)
  question.choices.each do |choice|
    puts "- #{choice.description}"
  end
  make_choice(question, taker)
end

def multiple_answer_q(question, taker)
  question.choices.each do |choice|
    puts "- #{choice.description}"
  end
  selection = nil
  until selection == 'N' || selection == 'NO'
    make_choice(question, taker)
    puts "Add another answer? (Y/N)"
    selection = gets.chomp.upcase
  end
end

def make_choice(question, taker)
  puts "Enter an answer:"
  choice = gets.chomp
  if choice.upcase == 'OTHER'
    puts "Enter your own choice"
    choice_obj = Choice.create({description: gets.chomp, question_id: question.id})
  else
    choice_obj = Choice.find_by description: choice
  end
  answer = Answer.create({question_id: question.id, choice_id: choice_obj.id, taker_id: taker.id})
end

def open_ended_q(question, taker)
  puts "Enter your answer here:"
  answer = gets.chomp
  choice = Choice.create({description: answer, question_id: question.id})
  Answer.create({question_id: question.id, choice_id: choice.id, taker_id: taker.id})
end


def show_completed_survey(survey, taker)
  survey.questions.each do |question|
    puts "\n #{question.description}"
    answers = Answer.where(question_id: question.id, taker_id: taker.id)
    answers.each do |answer|
      answer_chosen = Choice.find_by id: answer.choice_id
      puts "Answer: #{answer_chosen.description}"
    end
  end
end

def view_analytics
  view_surveys
  puts "View analytics for which survey?"
  index = gets.chomp.to_i
  survey = Survey.all[index - 1]
  survey.questions.each do |question|
    puts "\n #{question.description}"
    question.choices.each_with_index do |choice, index|
      puts "#{index + 1}. #{choice.description}"
      puts "Chosen by #{choice.answers.length} people (#{question.percentage(choice)}% of responses)"
    end
  end
end

welcome

