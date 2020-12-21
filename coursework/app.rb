#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'

set :database, {adapter: "sqlite3", database: "kurs.db"}

class User < ActiveRecord::Base
	validates :login, presence: true, uniqueness: true, length: {minimum: 5}
	validates :password, presence: true, length: {minimum: 5}
	validates :role, presence: true, inclusion: { in: %w(user doctor admin)}
end

class Doctor < ActiveRecord::Base
	validates :name, presence: true
	validates :position, presence: true
	validates :worktime, presence: true 
end

class Patient < ActiveRecord::Base
	validates :name, presence: true
	validates :birthdate, presence: true, length: {is: 10}
	validates :date_of_admission, presence: true, length: {is: 10} 
	validates :diagnosis, presence: true
	validates :date_of_discharged, presence: true, length: {is: 10} 
	validates :recommendation, presence: true
end

class Visitor < ActiveRecord::Base
	validates :name, presence: true
	validates :visit_datetime, presence: true, length: {is: 10} 
	validates :patient_name, presence: true
end

before do 
	@users = User.all
	@doctors = Doctor.all
	@patients = Patient.all
	@visitors = Visitor.all
end

get '/' do
	erb :home
end

get '/authorization/login' do
	erb :login
end

post '/authorization' do
	@login = params[:login]
	@password = params[:password]
	@user = User.find_by(login: @login, password: @password)
	if @user && @user.role == "user"
		erb :usershome
	elsif @user && @user.role == "doctor"
		erb :doctorshome
	elsif @user && @user.role == "admin"
		erb :adminshome
	else
		erb :login_help
	end
end

get '/registrations/signup' do
	erb :signup
end

post '/registrations' do
	@login = params[:login]
	@password = params[:password]
	@role = "user"
	@user = User.new(login: @login, password: @password, role: @role)
	@user.save
	if @user.save
		erb :usershome
	else
		if @login.size < 5 || @password.size < 5
			@warning = "Пароль и логин должны иметь минимум 5 символов!"
		else
			@warning = "Такой логин уже существует!"
		end
		erb :signup_help
	end
end

get '/information/doctors' do
	if $role_final==""
		redirect '/'
	else
	erb :doctors
end
end

get '/information/doctors_sort_by_name' do
	@doctors_sort_by_name = Doctor.order("name")
	erb :doctors_sort_by_name
end

get '/information/doctors_sort_by_position' do
	@doctors_sort_by_position = Doctor.order("position")
	erb :doctors_sort_by_position
end

get '/information2/patients' do
	if $role_final==""
		redirect '/'
	elsif $role_final=="user"
		erb :usershome_fail
	else
		erb :patients
	end
end

get '/information2/patients_sort_by_name' do
	@patients_sort_by_name = Patient.order("name")
	erb :patients_sort_by_name
end

get '/information2/patients_sort_by_diagnosis' do
	@patients_sort_by_diagnosis = Patient.order("diagnosis")
	erb :patients_sort_by_diagnosis
end

get '/information2/patients_sort_by_date' do
	@patients_sort_by_date = Patient.order("date_of_admission")
	erb :patients_sort_by_date
end

get '/information3/visitors' do
	if $role_final==""
		redirect '/'
	elsif $role_final=="user"
		erb :usershome_fail
	else
		erb :visitors
	end
end

get '/information3/visitors_sort_by_name' do
	@visitors_sort_by_name = Visitor.order("name")
	erb :visitors_sort_by_name
end

get '/information3/visitors_sort_by_date' do
	@visitors_sort_by_date = Visitor.order("visit_datetime")
	erb :visitors_sort_by_date
end


get '/information3/visitors_sort_by_patients_name' do
	@visitors_sort_by_patients_name = Visitor.order("patient_name")
	erb :visitors_sort_by_patients_name
end

get '/redact1/main' do
	if $role_final==""
		redirect '/'
	elsif $role_final=="user"
		erb :usershome_fail
	else
		erb :redact1_main
	end
end

get '/redact2/main' do
	if $role_final==""
		redirect '/'
	elsif $role_final=="user"
		erb :usershome_fail
	elsif $role_final=="doctor"
		erb :doctorshome_fail
	else
		erb :redact2_main
	end
end

get '/show_user/main' do
	erb :show_user
end

post '/show_user/main' do
	@search = params[:search]
	@users_search_by_login = User.where('login LIKE ?', "%#{@search}%")
	@users_search_by_role = User.where('role LIKE ?', "%#{@search}%")
	return erb :users_search
end

get '/show_user/sort_by_login' do
	@users_sort_by_login = User.order("login")
	erb :show_user_sort_by_login
end

get '/show_user/sort_by_role' do
	@users_sort_by_role = User.order("role")
	erb :show_user_sort_by_role
end

get '/add_user/main' do
	erb :add_user
end

post '/add_user/main' do
	user = User.new params[:user]
	user.save
	if user.save
		erb :add_user_success
	else
		erb :add_user_fail
	end
end

get '/delete_user/main' do
	erb :delete_user
end

post '/delete_user/main' do
	@delete = params[:delete]
	user = User.find_by_login("#{@delete}")
	check = user.to_s
	if check == ""
		erb :delete_user_fail
	else
		user.destroy
		erb :delete_user_success
	end
end

get '/rewrite_user/main' do
	erb :rewrite_user
end

post '/rewrite_user/main' do
	@rewrite = params[:rewrite]
	user = User.find_by_login("#{@rewrite}")
	check = user.to_s
	if check == ""
		erb :rewrite_user_fail
	else
		$user = user
		redirect '/rewrite_user/main/go'
	end
end

get '/rewrite_user/main/go' do
	erb :rewrite_user_go
end

post '/rewrite_user/main/go' do
	@login = params[:login]
	@password = params[:password]
	@role = params[:role]

	$user.update(login:    @login,
						 password: @password,
						 role: @role
						 )

	if @login == "" || @password == "" || @role == "" 
		erb :rewrite_user_go_fail
	else
		erb :rewrite_user_go_success
	end
end

get '/add/main' do
	erb :add_main
end

get '/add/main/add_patient' do
	erb :add_patient
end

get '/add/main/add_visitor' do
	erb :add_visitor
end

get '/add/main/add_doctor' do
	erb :add_doctor
end

get '/delete/main' do
	erb :delete_main
end

get '/delete/main/delete_patient' do
	erb :delete_patient
end

get '/delete/main/delete_visitor' do
	erb :delete_visitor
end

get '/delete/main/delete_doctor' do
	erb :delete_doctor
end

get '/rewrite/main' do
	erb :rewrite_main
end

get '/rewrite/main/rewrite_patient' do
	erb :rewrite_patient
end

get '/rewrite/main/rewrite_patient/go' do
	erb :rewrite_patient_go
end

get '/rewrite/main/rewrite_visitor' do
	erb :rewrite_visitor
end

get '/rewrite/main/rewrite_visitor/go' do
	erb :rewrite_visitor_go
end

get '/rewrite/main/rewrite_doctor' do
	erb :rewrite_doctor
end

get '/rewrite/main/rewrite_doctor/go' do
	erb :rewrite_doctor_go
end

post '/add/main/add_patient' do
	patient = Patient.new params[:patient]
	patient.save
	if patient.save
		erb :add_patient_success
	else
		erb :add_patient_fail
	end
end

post '/add/main/add_visitor' do
	visitor = Visitor.new params[:visitor]
	temp = visitor.name
	patient = Patient.find_by_name("#{temp}")
	check = patient.to_s
	if check != ""
			visitor.save
			if visitor.save
				erb :add_visitor_success
			else
				erb :add_visitor_fail
			end
		else
			erb :add_visitor_fail
	end
end

post '/add/main/add_doctor' do
	doctor = Doctor.new params[:doctor]
	doctor.save
	if doctor.save
		erb :add_doctor_success
	else
		erb :add_doctor_fail
	end
end

post '/delete/main/delete_patient' do
	@delete = params[:delete]
	patient = Patient.find_by_name("#{@delete}")
	check = patient.to_s
	if check == ""
		erb :delete_patient_fail
	else
		patient.destroy
		erb :delete_patient_success
	end
end

post '/delete/main/delete_visitor' do
	@delete = params[:delete]
	visitor = Visitor.find_by_name("#{@delete}")
	check = visitor.to_s
	if check == ""
		erb :delete_visitor_fail
	else
		visitor.destroy
		erb :delete_visitor_success
	end
end

post '/delete/main/delete_doctor' do
	@delete = params[:delete]
	doctor = Doctor.find_by_name("#{@delete}")
	check = doctor.to_s
	if check == ""
		erb :delete_doctor_fail
	else
		doctor.destroy
		erb :delete_doctor_success
	end
end

post '/rewrite/main/rewrite_patient' do
	@rewrite = params[:rewrite]
	patient = Patient.find_by_name("#{@rewrite}")
	check = patient.to_s
	if check == ""
		erb :rewrite_patient_fail
	else
		$patient = patient
		redirect '/rewrite/main/rewrite_patient/go'
	end
end

post '/rewrite/main/rewrite_patient/go' do
	@name = params[:name]
	@birthdate = params[:birthdate]
	@date_of_admission = params[:date_of_admission]
	@diagnosis = params[:diagnosis]
	@date_of_discharged = params[:date_of_discharged]
	@recommendation = params[:recommendation]

	$patient.update(name:    @name,
						 birthdate: @birthdate,
						 date_of_admission: @date_of_admission,
						 diagnosis: @diagnosis,
						 date_of_discharged: @date_of_discharged,
						 recommendation: @recommendation
						 )

	if @name == "" || @birthdate == "" || @date_of_admission == "" || @diagnosis == "" || @date_of_discharged == "" || @recommendation == "" 
		erb :rewrite_patient_go_fail
	else
		erb :rewrite_patient_go_success
	end
end

post '/rewrite/main/rewrite_visitor' do
	@rewrite = params[:rewrite]
	visitor = Visitor.find_by_name("#{@rewrite}")
	check = visitor.to_s
	if check == ""
		erb :rewrite_visitor_fail
	else
		$visitor = visitor
		redirect '/rewrite/main/rewrite_visitor/go'
	end
end

post '/rewrite/main/rewrite_visitor/go' do
	@name = params[:name]
	@visit_datetime = params[:visit_datetime]
	@patient_name = params[:patient_name]

	patient = Patient.find_by_name("#{@patient_name}")
	check = patient.to_s
	if check != ""
		$visitor.update(name:    @name,
			visit_datetime: @visit_datetime,
			patient_name: @patient_name)

					if @name == "" || @visit_datetime == ""
							erb :rewrite_visitor_go_fail
					else
							erb :rewrite_visitor_go_success
					end
	
	else

		erb :rewrite_visitor_go_fail

	end

end


post '/rewrite/main/rewrite_doctor' do
	@rewrite = params[:rewrite]
	doctor = Doctor.find_by_name("#{@rewrite}")
	check = doctor.to_s
	if check == ""
		erb :rewrite_doctor_fail
	else
		$doctor = doctor
		redirect '/rewrite/main/rewrite_doctor/go'
	end
end

post '/rewrite/main/rewrite_doctor/go' do
	@name = params[:name]
	@position = params[:position]
	@worktime = params[:worktime]

	$doctor.update(name:    @name,
						 position: @position,
						 worktime: @worktime
						 )

	if @name == "" || @position == "" || @worktime == "" 
		erb :rewrite_doctor_go_fail
	else
		erb :rewrite_doctor_go_success
	end
end

post '/information' do
	@search = params[:search]
	@doctors_search_by_name = Doctor.where('name LIKE ?', "%#{@search}%")
	@doctors_search_by_position = Doctor.where('position LIKE ?', "%#{@search}%")
	return erb :doctors_search
end

post '/information2' do
	@search = params[:search]
	@patients_search_by_name = Patient.where('name LIKE ?', "%#{@search}%")
	@patients_search_by_diagnosis = Patient.where('diagnosis LIKE ?', "%#{@search}%")
	@patients_search_by_date = Patient.where('date_of_admission LIKE ?', "%#{@search}%")
	return erb :patients_search
end

post '/information3' do
	@search = params[:search]
	@visitors_search_by_name = Visitor.where('name LIKE ?', "%#{@search}%")
	@visitors_search_by_date = Visitor.where('visit_datetime LIKE ?', "%#{@search}%")
	@visitors_search_by_patients_name = Visitor.where('patient_name LIKE ?', "%#{@search}%")
	return erb :visitors_search
end