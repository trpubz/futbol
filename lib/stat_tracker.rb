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

  # return: hash of all for all seasons {team_id => avg_goals}
  def team_avg_goals
    team_goals = Hash.new { |hash, key| hash[key] = [] }
    @game_teams_data.each do |game|
      team_goals[game[:team_id]] << game[:goals].to_i
    end

    team_goals.transform_values! do |goals|
      (goals.reduce(:+) / goals.size.to_f).round(1)
    end
    team_goals
  end

  def best_offense
    team_id = team_avg_goals.max[0]  # max => [team_id, value] from hash

    team_name_from_id(team_id)
  end

  def worst_offense
    team_id = team_avg_goals.min[0]

    team_name_from_id(team_id)
  end

  private
end