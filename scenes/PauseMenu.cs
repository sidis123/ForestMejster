using Godot;
using System;

public partial class PauseMenu : Control
{
	[Signal]
	public delegate void PausedEventHandler();
	
	[Signal]
	public delegate void UnpausedEventHandler();
	
	private Node3D pauseMenuContainer;
	private bool paused = false;
	
	public float DistanceInFront = 1.0f; // Distance in front of the player to place the container
	private XROrigin3D player;
	private XRCamera3D camera;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Retrieve the menu container
		pauseMenuContainer = GetNode<Node3D>("/root/Main/PauseMenuContainer"); // TODO: A better routing solution

		if (pauseMenuContainer == null)
		{
			GD.Print("Pause menu error: PauseMenuContainer node was not found!");
		}
		
		// Retrieve the player
		player = GetNode<XROrigin3D>("/root/Main/XROrigin3D"); // TODO: A better routing solution
		
		if (player == null)
		{
			GD.Print("Pause menu error: Player node was not found!");
		}
		else
		{
			camera = player.GetNode<XRCamera3D>("XRCamera3D");
			if(camera == null)
			{
				GD.Print("Pause menu error: Player camera was not found!");
			}
		}
		
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if(paused){
			PositionMenuInFrontOfPlayer();
		}
		
		if (Input.IsActionJustPressed("pause"))
		{
			paused = !paused; // change the current pause state
			if (paused) {
				Pause();
			}
			else{
				Unpause();
			}
		}
	}
	
	private void PositionMenuInFrontOfPlayer()
	{
		// Calculate the forward direction of the player camera from its rotation
		Vector3 forwardDir = camera.GlobalTransform.Basis.Z.Normalized();
		
		// Calculate and set new position for menu, in front of camera
		Vector3 newPosition = camera.GlobalTransform.Origin - forwardDir * DistanceInFront;
		pauseMenuContainer.Position = new Vector3(newPosition.X, newPosition.Y, newPosition.Z);

		// Make the menu face the player
		pauseMenuContainer.LookAt(camera.GlobalTransform.Origin, Vector3.Up);
		pauseMenuContainer.Rotate(pauseMenuContainer.Transform.Basis.Y.Normalized(), Mathf.Pi);
	}
	
	private void Pause(){
		if (pauseMenuContainer != null)
		{
			PositionMenuInFrontOfPlayer();
			pauseMenuContainer.Visible = true;
			pauseMenuContainer.Set("enabled", true);
		}
		GetTree().Paused = true;
		EmitSignal(SignalName.Paused);
	}
	
	private void Unpause(){
		if (pauseMenuContainer != null)
		{
			pauseMenuContainer.Visible = false;
			pauseMenuContainer.Set("enabled", false);
		}
		GetTree().Paused = false;
		EmitSignal(SignalName.Unpaused);
	}

	private void OnResumeButtonPressed()
	{
		paused = false;
		Unpause();
	}
	
	private void OnSettingsButtonPressed()
	{
		// Replace with function body.
	}
	
	private void OnExitToMenuButtonPressed()
	{
		// Replace with function body.
	}

	private void OnExitGameButtonPressed()
	{
		GetTree().Quit();
	}	
}
