class SupportsController < ApplicationController
  include SlackNotifing

  def create
    @target = Stand.find params[:target_id]
    @poster = @target.poster
    unless @poster.has_stand_of?(current_user)
      # flash[:error] = "#{current_user.email}의 의견이 없습니다."
      # redirect_to @poster and return
      @stand = @poster.stands.build({versions_attributes: {'0': { choice: 'abstain' }}})
      @stand.user = current_user
    else
      @stand = @poster.stand_of(current_user)
    end
    @support = @stand.supports.build(target: @target)
    @stand.save!

    @target.touch
    @target.save!

    slack(@support)

    redirect_to @poster
  end

  def destroy
    @support = Support.find params[:id]
    @stand = @support.stand
    @target = @support.target

    @stand.supports.destroy @support
    @stand.save!

    @target.touch
    @target.save!

    slack(@support)

    @poster = @target.poster
    redirect_to @poster
  end

end
