class Team
  attr_reader :team_id,
    :franchiseid,
    :team_name,
    :abbreviation,
    :link

  def initialize(team_data)
    @team_id = team_data[:team_id]
    @franchiseid = team_data[:franchiseid]
    @team_name = team_data[:teamname]
    @abbreviation = team_data[:abbreviation]
    @link = team_data[:link]
  end

  def as_hash
    {@team_id => {
      "team_id" => @team_id,
      "franchise_id" => @franchiseid,
      "team_name" => @team_name,
      "abbreviation" => @abbreviation,
      "link" => @link
    }}
  end
end
