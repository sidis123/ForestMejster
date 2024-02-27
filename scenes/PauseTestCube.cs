using Godot;
using System;

public partial class PauseTestCube : MeshInstance3D
{
	private float speed = 5.0f;
	private float range = 2.0f;
	private Vector3 originalPosition;
	private float[] movementRange;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		originalPosition = this.Position;
		movementRange = new float[2]{originalPosition.X - range, originalPosition.X + range};
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Position.X <= movementRange[0] || Position.X >= movementRange[1]){
			speed = speed * -1.0f;
		}
			
		float newX = Position.X + speed*(float)delta;
		Position = new Vector3(newX, Position.Y, Position.Z);
	}
}
