package modloader;

#if sys
import flixel.FlxSubState;
import polymod.Polymod.ModMetadata;
import modloader.ModList;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;

 class ModsMenuOption extends FlxTypedGroup<FlxSprite>
 {
	public var Alphabet_Text:Alphabet;
	public var Mod_Icon:ModIcon;

	public var Mod_Enabled:Bool = false;

	public var Option_Row:Int = 0;

	public var Option_Name:String = "-";
	public var Option_Value:String = "Template Mod";
	
	public function new(_Option_Name:String = "-", _Option_Value:String = "Template Mod", _Option_Row:Int = 0)
	{
		super();

		this.Option_Name = _Option_Name;
		this.Option_Value = _Option_Value;
		this.Option_Row = _Option_Row;

		Alphabet_Text = new Alphabet(0, 0 + (Option_Row * 100), Option_Name, true);
		Alphabet_Text.isMenuItem = true;
		Alphabet_Text.targetY = Option_Row;
		add(Alphabet_Text);

		Mod_Icon = new ModIcon(Option_Value);
		Mod_Icon.sprTracker = Alphabet_Text;
		add(Mod_Icon);

		Mod_Enabled = ModList.modList.get(Option_Value);

		FlxG.mouse.visible = true;
	}

	override function update(elapsed:Float)
	{

		super.update(elapsed);

		var enableButton:FlxButton = new FlxButton(920, 620, "Enable Mod", function()
		{
			Mod_Enabled = true;
		});
		enableButton.setGraphicSize(150, 70);
		enableButton.updateHitbox();
		enableButton.label.y += 22;
		enableButton.label.fieldWidth = 135;
		enableButton.label.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		add(enableButton);
		
		var disableButton:FlxButton = new FlxButton(1100, 620, "Disable Mod", function()
		{
			Mod_Enabled = false;
		});
		
		disableButton.setGraphicSize(150, 70);
		disableButton.updateHitbox();
		disableButton.label.y += 22;
		disableButton.label.fieldWidth = 135;
		disableButton.label.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		add(disableButton);
	
		if(Mod_Enabled)
		{
			Alphabet_Text.color = FlxColor.GREEN;
		}
		else
		{
			Alphabet_Text.color = FlxColor.RED;
		}
	}
}
#end
