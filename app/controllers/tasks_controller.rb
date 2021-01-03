class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]

  # GET /tasks
  # GET /tasks.json
  def index
    tasks = Task.all
    render json: { tasks: tasks }
  end

  # PUT /tasks
  # For sorting tasks
  def index_query
    @sort_field = params[:sortField]
    @sort_order = params[:sortOrder].upcase # DESC or ASC
    @search_field = params[:searchField]
    @search_string = params[:searchString]

    @non_empty_tasks = Task.where.not("#{@sort_field}": nil)
    @non_empty_tasks = @non_empty_tasks.where.not("#{@sort_field}": 0) if @sort_field.to_s == 'priority'
    # if no priority field in task

    @searched_tasks = case @search_field.to_s
                      when 'all'
                        search_tags
                      .or(search_deadline)
                      .or(search_description)
                      .or(search_title)
                      .or(search_priority)
                      when 'tags'
                        search_tags
                      when 'deadline'
                        search_deadline
                      when 'description'
                        search_description
                      when 'title'
                        search_title
                      when 'priority'
                        search_priority
                      else
                        render json: { errors: 'No such field' }, status: :unprocessable_entity
                      end

    @sorted_tasks = @searched_tasks.order("#{@sort_field} #{@sort_order}")

    render json: { tasks: @sorted_tasks }
  end

  # GET /tasks/:id
  def show
    task = Task.find(params[:id])
    render json: task
  end

  # GET /tasks/new
  def new
    task = Task.new
  end

  # GET /tasks/1/edit
  def edit; end

  # POST /tasks
  # POST /tasks.json
  def create
    task = Task.new(task_params)

    if task.save
      render json: task
    else
      render json: task.errors, status: :unprocessable_entity
    end

  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    task = Task.find(params[:id])
    if task.update(task_params)
      render json: task
    else
      render json: task.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    task = Task.find(params[:id])
    if task.destroy
      head :no_content, status: :ok # render just the header
    else
      render json: task.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tasks
  # DELETE /tasks.json
  def destroy_all
    if Task.destroy_all
      head :no_content, status: :ok # render just the header
    else
      render json: Task.errors, status: :unprocessable_entity
    end
  end

  ########################################### Private methods ######################################################

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:title, :description, :priority, :deadline, :progress, tags: [])
  end

  def search_tags
    @non_empty_tasks.where("array_to_string(tags, ', ') ILIKE ? ", "%#{@search_string}%")
  end

  def search_deadline
    @non_empty_tasks.where("TO_CHAR(deadline, 'DD/MM/YYYY')  ILIKE ?",
                           "%#{@search_string}%")
                    .or(@non_empty_tasks.where("TO_CHAR(deadline, 'DD-MM-YYYY')  ILIKE ?",
                                               "%#{@search_string}%"))
                    .or(@non_empty_tasks.where("TO_CHAR(deadline, 'DD MM YYYY')  ILIKE ?",
                                               "%#{@search_string}%"))
  end

  def search_description
    @non_empty_tasks.where('description ILIKE ?', "%#{@search_string}%")
  end

  def search_title
    @non_empty_tasks.where('title ILIKE ?', "%#{@search_string}%")
  end

  def search_priority
    priorities = Task.priorities
                     .select { |key, _value| key.to_s.downcase.include? @search_string.to_s.downcase }
                     .values
    @non_empty_tasks.where(priority: priorities)
  end
end
