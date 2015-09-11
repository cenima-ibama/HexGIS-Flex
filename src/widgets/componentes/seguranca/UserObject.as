package widgets.componentes.seguranca
{
	public class UserObject extends Object
	{
		private var _nome:String;
		private var _cpf:String;
		private var _email:String;
		private var _configXml:String;
		
		public function UserObject()
		{
			super();
		}
		
		public function  get nome():String
		{
			return this._nome;
		}
		
		public function set nome(value:String):void
		{
			this._nome = value;
		}
		
		public function  get cpf():String
		{
			return this._cpf;
		}
		
		public function set cpf(value:String):void
		{
			this._cpf = value;
		}
		
		public function  get email():String
		{
			return this._email;
		}
		
		public function set email(value:String):void
		{
			this._email = value;
		}
		
		public function  get configXml():String
		{
			return this._configXml;
		}
		
		public function set configXml(value:String):void
		{
			this._configXml = value;
		}
	}
}