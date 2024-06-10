using UnityEngine;
using UnityEngine.UI;

public class PlayerHealth : MonoBehaviour
{
    public int startingHealth = 100;
    public Slider healthSlider;

    public static int playerScore = 0;
    public Text scoreText;

    int currentHealth;

    void Start()
    {
        currentHealth = startingHealth;
        healthSlider.value = currentHealth;
        SetScoreText();
    }

    public void SetScoreText()
    {
        if (scoreText != null)
        {
            scoreText.text = "Enemies Down: " + playerScore.ToString();
        }
        else
        {
            Debug.LogWarning("Please set the score Text");
        }
    }

    public void TakeDamage(int damageAmount)
    {
        if (currentHealth > 0)
        {
            currentHealth -= damageAmount;
            healthSlider.value = currentHealth;
        }
        if (currentHealth <= 0)
        {
            PlayerDies();
        }
        Debug.Log("Current health " + currentHealth);
    }

    private void OnParticleCollision(GameObject other)
    {
        if (other.CompareTag("EnemyBullets"))
        {
            TakeDamage(5);
        }
    }

    void PlayerDies()
    {
        FindObjectOfType<LevelManager>().LevelLost();
        Debug.Log("Player is dead");

    }
}
