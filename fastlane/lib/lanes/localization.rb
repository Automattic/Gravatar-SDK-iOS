# frozen_string_literal: true


#################################################
# Lanes
#################################################

# Lanes related to Localization and GlotPress
#
platform :ios do
    # Generates the `.strings` file, by parsing source code (using `genstrings` under the hood).
    #
    lane :generate_strings_file do |options|
      generate_strings_file_demo(options)
      generate_strings_file_sdk(options)
    end
  
    lane :generate_strings_file_demo do |options|
      Dir.mktmpdir do |tempdir|
        demo_en_lproj = File.join('Demo', 'Demo', 'Localizations', 'en.lproj')
        ios_generate_strings_file_from_code(
          paths: [
            File.join('Demo', 'Demo', 'Gravatar-UIKit-Demo'),
            File.join('Demo', 'Demo', 'Gravatar-SwiftUI-Demo')
          ],
          output_dir: tempdir        )
  
        utf16_strings = File.join(tempdir, 'Localizable.strings')
        utf8_strings = File.join("..", demo_en_lproj, 'Localizable.strings')

        utf16_to_utf8(
          source: utf16_strings,
          destination: utf8_strings
        )
      end
    end
  
    lane :generate_strings_file_sdk do |options|
      Dir.mktmpdir do |tempdir|
        demo_en_lproj = File.join('Sources', 'GravatarUI', 'Resources', 'en.lproj')
        ios_generate_strings_file_from_code(
          paths: [
            File.join('Sources', 'GravatarUI')
          ],
          output_dir: tempdir
        )
  
        utf16_strings = File.join(tempdir, 'Localizable.strings')
        utf8_strings = File.join("..", demo_en_lproj, 'Localizable.strings')

        utf16_to_utf8(
          source: utf16_strings,
          destination: utf8_strings
        )
      end
    end
  
    private_lane :utf16_to_utf8 do |options|
      next unless options[:source]
      next unless options[:destination]      
  
      source = options[:source]
      destination = options[:destination]
  
      next unless File.exist?(source)
      File.open(source, "rb:UTF-16") do |in_file|
        utf16_content = in_file.read
        utf8_content = utf16_content.encode("UTF-8")

        File.open(destination, "w:UTF-8") do |out_file|
          out_file.write(utf8_content)
        end
      end
    end
  end
  