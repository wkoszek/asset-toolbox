#!/usr/bin/env ruby

require 'simple-spreadsheet'
require 'pp'
require 'yaml'

def get_header_line_num(ods)
  line_num = -1
  for rowi in 0..ods.size do
    line_num += 1
    row = ods[rowi]
    if row[0] == "Asset" then
      return line_num
    end
  end
  return -1
end

def devices_raw_get(ods, offset)
  hdr_line_num = get_header_line_num(ods)
  row = ods[hdr_line_num]
  return row[offset..-1]
end

# read all the junk from .ods
def ods_read(file_name)
  s = SimpleSpreadsheet::Workbook.read(file_name)
  s.selected_sheet = s.sheets.first

  rows = []
  s.first_row.upto(s.last_row) do |cell_line|
    one_row = []
    for coli in 1..20 do
      col_data = s.cell(cell_line, coli)
      if col_data == nil then
        col_data = ""
      end
      one_row.push(col_data)
    end
    rows.push(one_row)
  end
  return rows
end

def nicefy(ods)
  nice_data = Hash.new
  nice_data["devices"] = []

  # get device names
  dev_offset = 2
  devs = devices_raw_get(ods, dev_offset)

  # figure out where's the header
  hdr_line_num = get_header_line_num(ods)

  # for all actual data lines get name first, and device names
  # and pick resolutions from the table and generate the assets
  devs.each_with_index do |dev, devi|
    if dev.length == 0 then
      next
    end
    device = Hash.new
    device["devname"] = dev
    device["assets"] = []
    ods[hdr_line_num + 1..-1].each_with_index do |row, rowi|
      desc = row[0]
      name = row[1]
      resolution = row[2 + devi]

      asset = Hash.new
      asset["name"] = name
      asset["resolution"] = resolution

      device["assets"].push(asset)

      #print "#{name} #{dev} #{resolution}\n"
    end
    nice_data["devices"].push(device)
  end
  return nice_data
end

def main
  data = ods_read("./asset-toolbox.ods")
  data_nice = nicefy(data)
  print data_nice.to_yaml
end

main
