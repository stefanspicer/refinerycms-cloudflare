# encoding: utf-8
require "spec_helper"

describe Refinery do
  describe "Cloudflare" do
    describe "Admin" do
      describe "purges", type: :feature do
        refinery_login

        describe "purges list" do
          before do
            FactoryGirl.create(:purge, :context => "UniqueTitleOne")
            FactoryGirl.create(:purge, :context => "UniqueTitleTwo")
          end

          it "shows two items" do
            visit refinery.cloudflare_admin_purges_path
            expect(page).to have_content("UniqueTitleOne")
            expect(page).to have_content("UniqueTitleTwo")
          end
        end

        describe "create" do
          before do
            visit refinery.cloudflare_admin_purges_path

            click_link "Add New Purge"
          end

          context "valid data" do
            it "should succeed" do
              fill_in "Context", :with => "This is a test of the first string field"
              expect { click_button "Save" }.to change(Refinery::Cloudflare::Purge, :count).from(0).to(1)

              expect(page).to have_content("'This is a test of the first string field' was successfully added.")
            end
          end

          context "invalid data" do
            it "should fail" do
              expect { click_button "Save" }.not_to change(Refinery::Cloudflare::Purge, :count)

              expect(page).to have_content("Context can't be blank")
            end
          end

          context "duplicate" do
            before { FactoryGirl.create(:purge, :context => "UniqueTitle") }

            it "should fail" do
              visit refinery.cloudflare_admin_purges_path

              click_link "Add New Purge"

              fill_in "Context", :with => "UniqueTitle"
              expect { click_button "Save" }.not_to change(Refinery::Cloudflare::Purge, :count)

              expect(page).to have_content("There were problems")
            end
          end

        end

        describe "edit" do
          before { FactoryGirl.create(:purge, :context => "A context") }

          it "should succeed" do
            visit refinery.cloudflare_admin_purges_path

            within ".actions" do
              click_link "Edit this purge"
            end

            fill_in "Context", :with => "A different context"
            click_button "Save"

            expect(page).to have_content("'A different context' was successfully updated.")
            expect(page).not_to have_content("A context")
          end
        end

        describe "destroy" do
          before { FactoryGirl.create(:purge, :context => "UniqueTitleOne") }

          it "should succeed" do
            visit refinery.cloudflare_admin_purges_path

            click_link "Remove this purge forever"

            expect(page).to have_content("'UniqueTitleOne' was successfully removed.")
            expect(Refinery::Cloudflare::Purge.count).to eq(0)
          end
        end

      end
    end
  end
end
