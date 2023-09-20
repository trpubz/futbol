require "csv"

class StatTracker
  attr_reader :games_data, :teams_data, :game_teams_data

  def initialize(games_data, teams_data, game_teams_data)
    @games_data = games_data
    @teams_data = teams_data
    @game_teams_data = game_teams_data
  end

  def self.from_csv(locations)
    games_data = CSV.read(locations[:games], headers: true, header_converters: :symbol)
    teams_data = CSV.read(locations[:teams], headers: true, header_converters: :symbol)
    game_teams_data = CSV.read(locations[:game_teams], headers: true, header_converters: :symbol)

    new(games_data, teams_data, game_teams_data)
  end

  def team_name_from_id(team_id)
    @teams_data.each do |tm|
      return tm[:teamname] if tm[:team_id] == team_id
    end
  end

  def count_of_teams
    teams_data.size
  end

  # return: hash of all for all seasons {team_id => [goals]} => after reduce {team_id => avg_goals}
  def team_avg_goals(filter = nil, value = nil)
    team_goals = Hash.new { |hash, key| hash[key] = [] }
    @game_teams_data.each do |game|
      if filter.nil?
        team_goals[game[:team_id]] << game[:goals].to_i
      elsif game[filter] == value
        team_goals[game[:team_id]] << game[:goals].to_i
      end
    end

    team_goals.transform_values! do |goals|
      (goals.reduce(:+) / goals.size.to_f).round(1)
    end
    team_goals
  end

  def best_offense
    team_id = team_avg_goals.max_by { |k, v| v }[0]  # max => [team_id, value] from hash

    team_name_from_id(team_id)
  end

  def worst_offense
    team_id = team_avg_goals.min_by { |k, v| v }[0]

    team_name_from_id(team_id)
  end

  def highest_scoring_visitor
    team_id = team_avg_goals(:hoa, "away").max_by { |k, v| v }[0]

    team_name_from_id(team_id)
  end

  def highest_scoring_home_team
    team_id = team_avg_goals(:hoa, "home").max_by { |k, v| v }[0]

    team_name_from_id(team_id)
  end

  def lowest_scoring_visitor
    team_id = team_avg_goals(:hoa, "away").min_by { |k, v| v }[0]

    team_name_from_id(team_id)
  end

  def lowest_scoring_home_team
    team_id = team_avg_goals(:hoa, "home").min_by { |k, v| v }[0]

    team_name_from_id(team_id)
  end

  def coach_season_win_pct(season)
    season_games = []
    @games_data.each do |game|
      season_games << game[:game_id] if game[:season] == season
    end
    # iterate over @game_teams_mock to verify :game_id is .include? in predicate array
    # if :game_id is valid, use :head_coach name as hash key, and shovel :result onto hash value array
    coach_results = Hash.new { |hash, key| hash[key] = [] }
    @game_teams_data.each do |team_game|
      if season_games.include?(team_game[:game_id]) # game is in the queried season
        coach_results[team_game[:head_coach]] << team_game[:result]
      end
    end
    # with hash values arrays, use #transform_values! to reduce to win pct.
    coach_results.transform_values! do |results|
      (results.count("WIN") / results.size.to_f * 100.0).round(1)
    end
    coach_results
  end

  # @season: string of season year start finish: YYYYYYYY
  # @return: name of coach with highest winning pct.
  def winningest_coach(season)
    coach_results = coach_season_win_pct(season)

    coach_results.max_by { |k, v| v }[0]
  end

  def worst_coach(season)
    coach_results = coach_season_win_pct(season)

    coach_results.min_by { |k, v| v }[0]
  end

  def calculate_team_accuracies(season)
    team_accuracies = {}

    game_teams_in_season = @game_teams_data.select do |game_team|
      game_id = game_team[:game_id]
      game = @games_data.find { |game| game[:game_id] == game_id }
    
      if game && game[:season] == season
        true
      else
        false
      end
    end

   game_teams_in_season.each do |game_team|
    team_id = game_team[:team_id]
    goals = game_team[:goals].to_i
    shots = game_team[:shots].to_i

      if shots > 0
        accuracy_ratio = goals.to_f / shots
        team_accuracies[team_id] ||= [] 
        team_accuracies[team_id] << accuracy_ratio
      end
    end

    team_accuracies.each do |team_id, ratios|
      average_accuracy = (ratios.reduce(:+) / ratios.size).round(2)
      team_accuracies[team_id] = average_accuracy
    end

    team_accuracies
  end

  def most_accurate_team(season)
    team_accuracies = calculate_team_accuracies(season)

    most_accurate_team_id = team_accuracies.max_by { |_, ratio| ratio }.first

    team_name = @teams_data.find { |team| team[:team_id] == most_accurate_team_id }[:teamname]

    team_name
  end

end
