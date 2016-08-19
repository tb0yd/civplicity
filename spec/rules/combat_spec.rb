require 'spec_helper'

describe Combat do
  include Civplicity
  include Combat

  before { init_game }

  let(:unit) { Struct.new(:player, :type, :rank, :tile) }
  let(:with_city) { double(has_city?: true) }

  let(:friendly_settler) { unit.new(0, :Settler, nil, nil) }
  let(:friendly_archer) { unit.new(0, :Archer, nil, nil) }
  let(:friendly_veteran_archer) { unit.new(0, :Archer, :Veteran, nil) }
  let(:friendly_tank) { unit.new(0, :Tank, nil, nil) }
  let(:friendly_archer_in_city) { unit.new(0, :Archer, nil, with_city) }
  let(:friendly_infantry) { unit.new(0, :Infantry, nil, nil) }

  let(:enemy_settler) { unit.new(1, :Settler, nil, nil) }
  let(:enemy_archer) { unit.new(1, :Archer, nil, nil) }
  let(:enemy_veteran_archer) { unit.new(1, :Archer, :Veteran, nil) }
  let(:enemy_tank) { unit.new(1, :Tank, nil, nil) }
  let(:enemy_archer_in_city) { unit.new(1, :Archer, nil, with_city) }
  let(:enemy_infantry) { unit.new(1, :Infantry, nil, nil) }

  describe "#quality_of_defense" do
    it "is 0 for no opponent" do
      expect(quality_of_defense(friendly_archer, nil)).to be 0
    end

    it "is 1 for settler" do
      expect(quality_of_defense(friendly_archer, enemy_settler)).to be 1
    end

    it "is 2 for combatant" do
      expect(quality_of_defense(friendly_archer, enemy_archer)).to be 2
    end
  end

  describe "#choose_opponent_fairly" do
    it "chooses veteran against veteran" do
      opponent = choose_opponent_fairly(
        friendly_veteran_archer,
        [enemy_archer, enemy_veteran_archer, enemy_archer]
      )

      expect(opponent.rank).to eq :Veteran
    end

    it "chooses any rank against recruit" do
      opponent = choose_opponent_fairly(
        friendly_archer,
        [enemy_archer, enemy_veteran_archer, enemy_archer]
      )

      expect(opponent.rank).not_to eq :Veteran
    end
  end

  describe "#is_unlosable_challenge?" do
    it "is true for Tank vs. city" do
      res = is_unlosable_challenge?(friendly_tank, enemy_archer_in_city)
      expect(res).to be true
    end

    it "is false for city vs. Tank" do
      res = is_unlosable_challenge?(friendly_archer_in_city, enemy_tank)
      expect(res).to be false
    end

    it "is true for Veteran vs. recruit" do
      res = is_unlosable_challenge?(friendly_veteran_archer, enemy_archer)
      expect(res).to be true
    end

    it "is false for recruit vs. Veteran" do
      res = is_unlosable_challenge?(friendly_archer, enemy_veteran_archer)
      expect(res).to be false
    end

    it "is true for conscripted vs. non-conscripted" do
      res = is_unlosable_challenge?(friendly_infantry, enemy_archer)
      expect(res).to be true
    end

    it "is false for non-conscripted vs. conscripted" do
      res = is_unlosable_challenge?(friendly_archer, enemy_infantry)
      expect(res).to be false
    end

    it "is true for treaty breaking" do
      allow(self).to receive(:players_are_at_peace?) {true}
      res = is_unlosable_challenge?(friendly_archer, enemy_archer)
      expect(res).to be true
    end

    it "is false for any other match up" do
      any = [
        is_unlosable_challenge?(friendly_archer, enemy_archer),
        is_unlosable_challenge?(friendly_archer, enemy_settler),
        is_unlosable_challenge?(friendly_settler, enemy_archer),
        is_unlosable_challenge?(friendly_settler, enemy_archer_in_city)
      ].any?

      expect(any).to be false
    end
  end
end
