# frozen_string_literal: true

require "spec_helper"

describe "Visit a process group's landing page", type: :system, perform_enqueued: true do
  let!(:organization) { create :organization, available_locales: [:en] }
  let!(:participatory_process_group) { create :participatory_process_group, :with_participatory_processes, organization: organization }
  let!(:processes) { participatory_process_group.participatory_processes }

  context "when there are active alternative landing content blocks" do
    let!(:extra_title_block) { create(:extra_title_block, organization: organization, scoped_resource_id: participatory_process_group.id) }
    let!(:extra_information_block) { create(:extra_information_block, organization: organization, scoped_resource_id: participatory_process_group.id) }
    let!(:calendar_block) { create(:calendar_block, organization: organization, scoped_resource_id: participatory_process_group.id) }
    let!(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: processes.first) }
    let!(:meeting) { create(:meeting, start_time: Time.zone.now, end_time: Time.zone.now + 1.hour, component: meetings_component) }

    before do
      switch_to_host(organization.host)
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
    end

    it "renders them" do
      expect(page).to have_selector(".alternative-landing.calendar")
    end

    describe "extra title block" do
      it "renders all elements" do
        within ".alternative-landing.extra-title" do
          expect(page).to have_i18n_content(extra_title_block.settings.link_text_1)
          expect(page).to have_selector("[href='#{extra_title_block.settings.link_url_1}']")
          expect(page).to have_selector(".icon--instagram")
        end
      end
    end

    describe "extra information block" do
      it "renders all elements" do
        within ".alternative-landing.extra-information" do
          expect(page).to have_i18n_content(extra_information_block.settings.body)
        end
      end
    end

    describe "calendar block" do
      it "renders all elements" do
        within ".alternative-landing.calendar" do
          within ".calendar-filters" do
            expect(page).to have_button("Debate")
            expect(page).to have_button("Meeting")
            expect(page).to have_button("Survey")
            expect(page).to have_button("Participatory Process")
          end

          within "#calendar" do
            within ".fc-view-container" do
              expect(page).to have_i18n_content(meeting.title)
              expect(page).to have_content(meeting.start_time.strftime("%H:%M"))
            end
          end
        end
      end
    end
  end
end