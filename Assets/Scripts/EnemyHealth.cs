using UnityEngine;
using UnityEngine.UI;

public class EnemyHealth : MonoBehaviour
{
    public int startingHealth = 100;
    public Slider healthSlider;

    public int currentHealth;

    void Awake()
    {
        healthSlider = GetComponentInChildren<Slider>();
    }

    void Start()
    {
        currentHealth = startingHealth;
        healthSlider.value = currentHealth;
    }


    public void TakeDamage(int damageAmount)
    {
        if (currentHealth > 0)
        {
            currentHealth -= damageAmount;
            healthSlider.value = currentHealth;

            Debug.Log($"Enemy takes {damageAmount} damage, current health: {currentHealth}");

            if (currentHealth <= 0)
            {
                // Ensure health slider reflects 0 health.
                healthSlider.value = 0;
                Debug.Log("Enemy health has reached zero.");
                Destroy(gameObject);
            }
        }
    }

    private void OnParticleCollision(GameObject other)

    {
        if (other.CompareTag("PlayerBullet"))
        {
            Debug.Log("PlayerBullet collided with enemy.");
            TakeDamage(50);
        }
    }
}
