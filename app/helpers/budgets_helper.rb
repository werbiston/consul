module BudgetsHelper

  def csv_params
    csv_params = params.clone.merge(format: :csv).symbolize_keys
    csv_params.delete(:page)
    csv_params
  end

  def budget_phases_select_options
    Budget::Phase::PHASE_KINDS.map { |ph| [ t("budgets.phase.#{ph}"), ph ] }
  end

  def budget_currency_symbol_select_options
    Budget::CURRENCY_SYMBOLS.map { |cs| [ cs, cs ] }
  end

  def namespaced_budget_investment_path(investment, options = {})
    case namespace
    when "management/budgets"
      management_budget_investment_path(investment.budget, investment, options)
    else
      budget_investment_path(investment.budget, investment, options)
    end
  end

  def namespaced_budget_investment_vote_path(investment, options = {})
    case namespace
    when "management/budgets"
      vote_management_budget_investment_path(investment.budget, investment, options)
    else
      vote_budget_investment_path(investment.budget, investment, options)
    end
  end

  def display_budget_countdown?(budget)
    budget.balloting?
  end

  def css_for_ballot_heading(heading)
    return '' if current_ballot.blank?
    current_ballot.has_lines_in_heading?(heading) ? 'active' : ''
  end

  def current_ballot
    Budget::Ballot.where(user: current_user, budget: @budget).first
  end

  def investment_tags_select_options
    Budget::Investment.tags_on(:valuation).order(:name).select(:name).distinct
  end

  def budget_published?(budget)
    !budget.drafting? || current_user&.administrator?
  end

  def current_budget_map_locations
    current_budget.investments.map do |investment|
      next unless investment.map_location.present?
      {
        lat: investment.map_location.latitude,
        long: investment.map_location.longitude,
        investment_title: investment.title,
        investment_id: investment.id,
        budget_id: current_budget.id
      }
    end.flatten.compact
  end
end
