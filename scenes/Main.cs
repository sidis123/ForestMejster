using Godot;
using System;

public partial class Main : Node3D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//PrintNodeTree(this);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		
	}
	
	private void PrintNodeTree(Node node, string indent = "")
	{
		GD.Print($"{indent}{node.Name} ({node.GetType().Name})");
		foreach (Node child in node.GetChildren())
		{
			PrintNodeTree(child, indent + "--");
		}
	}
}
