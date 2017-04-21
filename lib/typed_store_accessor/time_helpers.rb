module TypedStoreAccessor
  module TimeHelpers
    private

    def parse_time(string)
      if string == "NA" || string.blank?
        nil
      elsif (string =~ /\d{1,2}\/\d{1,2}\/\d{2}$/)
        adjust_time_zone Time.strptime(string, "%m/%d/%y")
      elsif (string =~ /\d{1,2}\/\d{1,2}\/\d{4}$/)
        adjust_time_zone Time.strptime(string, "%m/%d/%Y")
      elsif (string =~ /\d{4}-\d{2}-\d{2}/)
        Time.zone.parse(string)
      elsif (string =~ /\d{1,2}-[A-Za-z]{3}-\d{4}/)
        Time.zone.parse(string)
      elsif (string =~ /\d{1,2}-[A-Za-z]{3}-\d{2}/)
        time = Time.zone.parse(string)
        time.change(year: 2000 + time.year)
      elsif (string =~ /[A-Za-z]{3},?\s+\d{1,2},?\s+\d{4}/)
        Time.zone.parse(string)
      elsif (string =~ /[A-Za-z]{3},?\s+\d{1,2},?\s+\d{2}/)
        time = Time.zone.parse(string)
        time.change(year: 2000 + time.year)
      elsif (string =~ /[A-Za-z]{3},?\s+\d{1,2},\s*\d{4}/)
        Time.zone.parse(string)
      elsif (string =~ /[A-Za-z]{3},?\s+\d{1,2},\s*\d{2}/)
        time = Time.zone.parse(string)
        time.change(year: 2000 + time.year)
      elsif (string =~ /\d{4}-\d{2}-\d{2}/)
        Time.zone.parse(string)
      elsif (string =~ /\d{1,2}\/\d{1,2}\/\d{4} \d{2}:\d{2}/)
        adjust_time_zone Time.strptime("#{string}", "%m/%d/%Y %H:%M")
      elsif (string =~ /\d{1,2}\/\d{1,2}\/\d{2} \d{1,2}:\d{2}/)
        adjust_time_zone Time.strptime("#{string}", "%m/%d/%y %H:%M")
      else
        adjust_time_zone Time.strptime("#{string} UTC", "%m/%d/%Y %H:%M%P %Z")
      end
    end

    def adjust_time_zone(time)
      Time.zone.parse(time.to_s(:db))
    end
  end
end
