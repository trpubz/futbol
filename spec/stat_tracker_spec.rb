require "./spec/spec_helper"

RSpec.describe StatTracker do

  before :each do
    game_path = "./data/games_mock.csv"
    team_path = "./data/teams.csv"
    game_teams_path = "./data/game_teams_mock.csv"

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    @stat_tracker = StatTracker.from_csv(locations)
  end

  describe "#highest_total_score" do
    it "returns the highest total score" do
      expect(@stat_tracker.highest_total_score).to eq(5)
    end
  end

  describe "#lowest_total_score" do
    it "returns the lowest total score" do
      expect(@stat_tracker.lowest_total_score).to eq(3)
    end
  end

  describe "#count_of_games_by_season" do
    it "returns the number of games in a season" do

      expected_outcome = {
        '20122013' => 8,
        '20132014' => 2
      }
      expect(@stat_tracker.count_of_games_by_season).to eq(expected_outcome)
    end
  end

  describe "average_goals_per_game" do
    it "should return the average goals per game" do
      expect(@stat_tracker.average_goals_per_game).to eq(4.3)  
    end
  end

  describe "average_points_per_game" do
    

  end
end
