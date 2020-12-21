class Kurs < ActiveRecord::Migration[6.1]
  def change
  	create_table :users do |u|
  		u.text :login
  		u.text :password
  		u.text :role
  	end

  	create_table :doctors do |d|
  		d.text :name
  		d.text :position 
  		d.text :worktime
  	end

  	create_table :patients do |p|
  		p.text :name
  		p.date :birthdate
  		p.date :date_of_admission
  		p.text :diagnosis
  		p.date :date_of_discharged
  		p.text :recommendation

  	end

  	create_table :visitors do |v|
  		v.text :name
  		v.date :visit_datetime
  		v.text :patient_name
  	end
  end
end
