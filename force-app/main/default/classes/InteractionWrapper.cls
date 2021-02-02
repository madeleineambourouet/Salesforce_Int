public class InteractionWrapper {
	public Event eve {get;set;}
	public Task task {get;set;}
	public Integer countEvent {get;set;}
	public Integer countTask {get;set;}
	public String NameEve {get;set;}
	public String CreatedDateEve {get;set;}
	public String CreatedBYEve {get;set;}
	public String NameTask {get;set;}
	public String CreatedDateTask {get;set;}
	public String CreatedBYTask {get;set;}


	public InteractionWrapper() {
		this.NameEve = '';
		this.CreatedBYEve = '';
		this.CreatedDateEve = '';
		this.NameTask = '';
		this.CreatedBYTask = '';
		this.CreatedDateTask = '';

	}

	public void init()
	{
		if (this.eve != null && this.CreatedBYEve == '')
		{
			this.CreatedBYEve = this.eve.CreatedBY.Name;
			this.CreatedDateEve = this.eve.CreatedDate.format('dd/MM/yyyy');
		}

		if (this.task != null && this.CreatedBYTask == '')
		{
			this.CreatedBYTask = this.task.Owner.Name;
			this.CreatedDateTask = this.task.CreatedDate.format('dd/MM/yyyy');
		}
	}
}