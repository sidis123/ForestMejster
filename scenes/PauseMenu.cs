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
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		pauseMenuContainer = GetNode<Node3D>("/root/Main/PauseMenuContainer"); // TODO: A better routing solution

		if (pauseMenuContainer == null)
		{
			GD.Print("Error: PauseMenuContainer was not found!");
		}
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
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
	
	private void Pause(){
		if (pauseMenuContainer != null)
		{
			pauseMenuContainer.Visible = true;
		}
		GetTree().Paused = true;
		EmitSignal(SignalName.Paused);
	}
	
	private void Unpause(){
		if (pauseMenuContainer != null)
		{
			pauseMenuContainer.Visible = false;
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
