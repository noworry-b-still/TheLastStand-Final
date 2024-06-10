using UnityEngine;

public class GameMusicOnCamera : MonoBehaviour
{
    public AudioClip audioSFX; // Audio clip to play

    private AudioSource audioSource; // Reference to the AudioSource component

    void Start()
    {
        // Play the audio clip after a delay of 4 seconds
        Invoke("PlayDelayedAudio", 4f);
    }

    void PlayDelayedAudio()
    {
        // Check if an audio clip is assigned
        if (audioSFX != null)
        {
            // Create an AudioSource component if it doesn't exist
            if (audioSource == null)
            {
                audioSource = gameObject.AddComponent<AudioSource>();
            }

            // Set the audio clip to play
            audioSource.clip = audioSFX;

            // Set the audio clip to loop continuously
            audioSource.loop = true;

            // Play the audio clip
            audioSource.Play();
        }
        else
        {
            Debug.LogError("No audio clip assigned!");
        }
    }
}
