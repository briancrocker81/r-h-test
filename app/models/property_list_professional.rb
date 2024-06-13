class PropertyListProfessional < ApplicationRecord
  include FurnishedStatus
  mount_uploader :front_photo, AttachmentUploader
  LOCATIONS = [ 'Barne Barton', 'Boxhill', 'Cattedown', 'Compton', 'Coxside', 'Crabtree', 'Crownhill', 'Devonport',
                'Drake', 'Efford', 'Eggbuckland', 'Ernesettle', 'Estover', 'Glenholt', 'Greenbank', 'Ham', 'Hartley',
                'Hooe', 'Honicknowle', 'Keyham', 'King\'s Tamerton', 'Laira', 'Leigham', 'Lipson', 'Manadon', 'Mannamead',
                'Marsh Mills', 'Milehouse', 'Millbay', 'Millbridge', 'Morice Town', 'Mutley Plain', 'North Prospect',
                'Oreston', 'Pennycomequick', 'Pennycross', 'Peverell', 'Plympton', 'Plymstock', 'Roborough', 'St Budeaux',
                'St Judes', 'Southway', 'Stoke', 'Stonehouse', 'Tamerton Foliot', 'Thornbury', 'West Hoe', 'Weston Mill',
                'Whitleigh', 'Woolwell', 'City Center', 'Barbican' ]
  belongs_to :property


end
