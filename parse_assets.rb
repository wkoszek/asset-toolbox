#!/usr/bin/env ruby

require 'simple-spreadsheet'

s = SimpleSpreadsheet::Workbook.read('./asset-toolbox.ods')

s.selected_sheet = s.sheets.first

table_row = 0
saw_table_header = false
s.first_row.upto(s.last_row) do |line|
  data = s.cell(line, 1)
  if data == "Asset" then
    saw_table_header = true
    next
  end
  next unless saw_table_header
  name = s.cell(line, 2)
  print name + "\n"
end
