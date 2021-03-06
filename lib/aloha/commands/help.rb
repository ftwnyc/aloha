module Aloha
  module Commands
    class Help < SlackRubyBot::Commands::Base
      ALOHA_ATTACHMENT = {
                        fallback: "Visit https://github.com/ftwnyc/aloha for more info.",
                        author_name: "For the Win",
                        author_link: "http://ftw.nyc",
                        author_icon: "https://raw.githubusercontent.com/ftwnyc/aloha/custom-help-command/images/ftw-avatar.png",
                        title: "Aloha",
                        text: "An onboarding bot for busy admins and growing Slack teams.",
                        title_link: "https://aloha.ftw.nyc/"
                      }

      WIZARD_ATTACHMENT = {
                        fallback: "Visit https://aloha.ftw.nyc/app/wizard to set up messages for your team.",
                        title: "Aloha Setup Wizard",
                        text: "Use the wizard to set up messages for your team.",
                        title_link: "https://aloha.ftw.nyc/app/wizard",
                        color: "good"
                      }

      def self.call(client, data, match)
        attachments = [ALOHA_ATTACHMENT]
        client.web_client.chat_postMessage(channel: data.channel, text: self.general_text, attachments: attachments, link_names: true)
      end

      def self.general_text
        bot_desc = SlackRubyBot::Commands::Support::Help.instance.bot_desc_and_commands
        <<TEXT
#{bot_desc.join("\n")}

*More information:*
TEXT
      end

    end
  end
end
