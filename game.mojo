import pygame
import random

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH, SCREEN_HEIGHT = 400, 800  # More vertical aspect ratio
PLAYER_SIZE = 40
ENEMY_SIZE = 40
BULLET_SIZE = 5
PLAYER_COLOR = pygame.Color(255, 255, 255)  # Simplified colors
ENEMY_COLOR = pygame.Color(255, 255, 255)
BULLET_COLOR = pygame.Color(255, 255, 255)
BUNKER_COLOR = pygame.Color(128, 128, 128)
ENEMY_ROWS = 5
ENEMY_COLUMNS = 8
MOVEMENT_SPEED = 2  # More rigid movement
BULLET_SPEED = 5
BUNKER_SIZE = 50  # Larger, single rectangle bunkers
ENEMY_PROJECTILE_SPEED = 2
ENEMY_SHOOTING_RATE = 0.005  # Lower shooting rate

# Set up the display
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Space Invaders")

# Player setup
player = pygame.Rect(SCREEN_WIDTH // 2, SCREEN_HEIGHT - 2 * PLAYER_SIZE, PLAYER_SIZE, PLAYER_SIZE)

# Enemies setup
enemies = [pygame.Rect(col * (ENEMY_SIZE + 10), row * (ENEMY_SIZE + 10), ENEMY_SIZE, ENEMY_SIZE) for row in range(ENEMY_ROWS) for col in range(ENEMY_COLUMNS)]
enemy_speed = 1

# Bullets setup
bullets = []

# Bunkers setup
bunkers = [pygame.Rect(col * BUNKER_SIZE, SCREEN_HEIGHT - 150, BUNKER_SIZE, BUNKER_SIZE // 4) for col in range(3)]

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
                # Create a new bullet
                bullet = pygame.Rect(player.x + player.width // 2 - BULLET_SIZE // 2, player.y, BULLET_SIZE, BULLET_SIZE)
                bullets.append(bullet)

    # Player movement
    keys = pygame.key.get_pressed()
    if not game_over:
        if keys[pygame.K_LEFT] and player.x - MOVEMENT_SPEED > 0:
            player.x -= MOVEMENT_SPEED
        if keys[pygame.K_RIGHT] and player.x + MOVEMENT_SPEED + player.width < SCREEN_WIDTH:
            player.x += MOVEMENT_SPEED

    # Enemy movement
    if not game_over:
        move_down = False
        for enemy in enemies:
            enemy.x += enemy_speed
            if enemy.x >= SCREEN_WIDTH - ENEMY_SIZE or enemy.x <= 0:
                move_down = True
        if move_down:
            enemy_speed = -enemy_speed
            for enemy in enemies:
                enemy.y += 20  # Enemies move down more noticeably

        # Enemy shooting
        for enemy in enemies:
            if random.random() < ENEMY_SHOOTING_RATE:
                enemy_projectile = pygame.Rect(enemy.x + enemy.width // 2, enemy.y + enemy.height, BULLET_SIZE, BULLET_SIZE)
                enemy_projectiles.append(enemy_projectile)

    # Bullet movement and collision
    for bullet in bullets[:]:
        bullet.y -= BULLET_SPEED
        if bullet.y < 0:
            bullets.remove(bullet)
        for enemy in enemies[:]:
            if bullet.colliderect(enemy):
                bullets.remove(bullet)
                enemies.remove(enemy)

    # Enemy projectile movement and collision
    for projectile in enemy_projectiles[:]:
        projectile.y += ENEMY_PROJECTILE_SPEED
        if projectile.y > SCREEN_HEIGHT:
            enemy_projectiles.remove(projectile)
        elif projectile.colliderect(player):
            game_over = True
            enemy_projectiles.remove(projectile)

    # Drawing
    screen.fill((0, 0, 0))
    pygame.draw.rect(screen, PLAYER_COLOR, player)
    for enemy in enemies:
        pygame.draw.rect(screen, ENEMY_COLOR, enemy)
    for bullet in bullets:
        pygame.draw.rect(screen, BULLET_COLOR, bullet)
    for bunker in bunkers:
        pygame.draw.rect(screen, BUNKER_COLOR, bunker)
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
    clock.tick(20)  # Lower frame rate for a more Atari-like experience

# Quit Pygame
pygame.quit()
