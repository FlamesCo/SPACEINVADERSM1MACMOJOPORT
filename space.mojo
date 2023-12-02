import pygame
import random

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH, SCREEN_HEIGHT = 800, 600
PLAYER_SIZE = 50
ENEMY_SIZE = 50
PELLET_SIZE = 5
PLAYER_COLOR = pygame.Color(0, 255, 0)
ENEMY_COLOR = pygame.Color(255, 0, 0)
PELLET_COLOR = pygame.Color(255, 255, 255)
BUNKER_COLOR = pygame.Color(0, 128, 0)
ENEMY_ROWS = 5
ENEMY_COLUMNS = 10
MOVEMENT_SPEED = 3
PELLET_SPEED = 4
BUNKER_ROWS = 4
BUNKER_COLUMNS = 8
BUNKER_SIZE = 10
BUNKER_SPACING = 100
ENEMY_PROJECTILE_SPEED = 3
ENEMY_SHOOTING_RATE = 0.01
BUNKER_HEALTH = 3

# Set up the display
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Space Invaders")

# Player setup
player = pygame.Rect(SCREEN_WIDTH // 2, SCREEN_HEIGHT - 2 * PLAYER_SIZE, PLAYER_SIZE, PLAYER_SIZE)

# Enemies setup
enemies = [pygame.Rect(col * ENEMY_SIZE * 1.5, row * ENEMY_SIZE * 1.5, ENEMY_SIZE, ENEMY_SIZE) for row in range(ENEMY_ROWS) for col in range(ENEMY_COLUMNS)]
enemy_speed = 1

# Pellets setup
pellets = []

# Bunkers setup
bunkers = [{'rect': pygame.Rect(col * BUNKER_SIZE + bunker_x, row * BUNKER_SIZE + SCREEN_HEIGHT - 200, BUNKER_SIZE, BUNKER_SIZE), 'health': BUNKER_HEALTH} 
           for bunker_x in range(0, SCREEN_WIDTH, BUNKER_SPACING) 
           for row in range(BUNKER_ROWS) for col in range(BUNKER_COLUMNS)]

# Enemy projectiles
enemy_projectiles = []

# Game loop flag and clock
running = True
clock = pygame.time.Clock()

# Game over flag
game_over = False

# Main game loop
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        if not game_over and event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                pellet = pygame.Rect(player.x + player.width // 2 - PELLET_SIZE // 2, player.y, PELLET_SIZE, PELLET_SIZE)
                pellets.append(pellet)

    # Player movement
    keys = pygame.key.get_pressed()
    if not game_over:
        if keys[pygame.K_LEFT] and player.x - MOVEMENT_SPEED > 0:
            player.x -= MOVEMENT_SPEED
        if keys[pygame.K_RIGHT] and player.x + MOVEMENT_SPEED + player.width < SCREEN_WIDTH:
            player.x += MOVEMENT_SPEED

    # Enemy movement
    if not game_over:
        for enemy in enemies:
            enemy.x += enemy_speed
            if enemy.x >= SCREEN_WIDTH - ENEMY_SIZE or enemy.x <= 0:
                enemy_speed = -enemy_speed
                for e in enemies:
                    e.y += ENEMY_SIZE
            if random.random() < ENEMY_SHOOTING_RATE:
                enemy_projectile = pygame.Rect(enemy.x + enemy.width // 2, enemy.y + enemy.height, PELLET_SIZE, PELLET_SIZE)
                enemy_projectiles.append(enemy_projectile)

    # Pellet movement and collision
    for pellet in pellets[:]:
        pellet.y -= PELLET_SPEED
        if pellet.y < 0:
            pellets.remove(pellet)

    # Enemy projectile movement and collision
    projectiles_to_remove = []
    for projectile in enemy_projectiles[:]:
        projectile.y += ENEMY_PROJECTILE_SPEED
        if projectile.y > SCREEN_HEIGHT:
            projectiles_to_remove.append(projectile)
        else:
            for bunker in bunkers[:]:
                if projectile.colliderect(bunker['rect']):
                    bunker['health'] -= 1
                    projectiles_to_remove.append(projectile)
                    if bunker['health'] <= 0:
                        bunkers.remove(bunker)
                    break  # Stop checking other bunkers

    # Remove projectiles
    for projectile in projectiles_to_remove:
        if projectile in enemy_projectiles:
            enemy_projectiles.remove(projectile)

    # Drawing
    screen.fill((0, 0, 0))
    pygame.draw.rect(screen, PLAYER_COLOR, player)
    for enemy in enemies:
        pygame.draw.rect(screen, ENEMY_COLOR, enemy)
    for pellet in pellets:
        pygame.draw.rect(screen, PELLET_COLOR, pellet)
    for bunker in bunkers:
        pygame.draw.rect(screen, BUNKER_COLOR, bunker['rect'])
    for projectile in enemy_projectiles:
        pygame.draw.rect(screen, ENEMY_COLOR, projectile)

    # Game over text
    if game_over:
        font = pygame.font.Font(None, 36)
        text = font.render("Game Over", True, pygame.Color("white"))
        text_rect = text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2))
        screen.blit(text, text_rect)

    # Update the display
    pygame.display.flip()

    # Cap the frame rate
    clock.tick(30)

# Quit Pygame
pygame.quit()
