"""GrokHunter Discord bot — Coding Team presence for The Intelligent Playground.

Slash commands + mention replies. Token from DISCORD_TOKEN env.
Never commit the token.
"""

import os
import discord
from discord import app_commands
from discord.ext import commands
from dotenv import load_dotenv

load_dotenv()

TOKEN = os.getenv("DISCORD_TOKEN")
GUILD_ID = os.getenv("GUILD_ID")  # optional: faster slash sync

intents = discord.Intents.default()
intents.message_content = True  # for mentions

class GrokHunterBot(commands.Bot):
    def __init__(self):
        super().__init__(command_prefix="!", intents=intents)

    async def setup_hook(self):
        if GUILD_ID:
            guild = discord.Object(id=int(GUILD_ID))
            self.tree.copy_global_to(guild=guild)
            synced = await self.tree.sync(guild=guild)
            print(f"Synced {len(synced)} slash commands to guild {GUILD_ID}")
        else:
            synced = await self.tree.sync()
            print(f"Synced {len(synced)} global slash commands (may take up to 1h)")

bot = GrokHunterBot()

# --- Knowledge (from GrokHunter AGENTS.md / README) ---
AGENTS = {
    "coding-team": "Orchestrator: Design (Benjamin) → Build (Lucas) → Harden (Harper)",
    "benjamin": "Senior Architect — plan/read-only. Emits Design card.",
    "lucas": "Rapid Builder — shippable increments. Emits Build card.",
    "harper": "Reliability Engineer — tests, edge cases, phone-real failures. Emits Harden card.",
    "scout": "Fast map of tree / install flow (read-only).",
    "review": "Diff / change review.",
    "fix": "Surgical one-bug patches.",
    "overlay": "install.sh / overlay cache / PATH wrappers.",
    "desktop": "Termux:X11 / nh-x11 / proot desktop.",
    "host": "Termux host vs Kali guest.",
    "ship": "VERSION / changelog / release notes.",
    "docs": "README / FAQ / website copy.",
    "github": "git-identity / commits attach correctly.",
    "secrets": "secrets.env mode 600 hygiene.",
    "toolchain": "apt / compilers / build tools.",
    "tls": "Kali CA / SSL_CERT_FILE.",
    "net": "HTTPS probe / guest DNS.",
    "tookie": "Authorized public username OSINT (scoped).",
}

@bot.event
async def on_ready():
    print(f"GrokHunter online as {bot.user} (ID: {bot.user.id})")
    print("------")

@bot.tree.command(name="ping", description="Check bot latency")
async def ping(interaction: discord.Interaction):
    await interaction.response.send_message(f"Pong! {round(bot.latency * 1000)}ms")

@bot.tree.command(name="help", description="List available slash commands")
async def help_cmd(interaction: discord.Interaction):
    embed = discord.Embed(
        title="GrokHunter Slash Commands",
        description="Coding Team presence for The Intelligent Playground.",
        color=0x00E5C7,
    )
    embed.add_field(name="/ping", value="Latency check", inline=False)
    embed.add_field(name="/status", value="Version, links, install one-liner", inline=False)
    embed.add_field(name="/agents", value="Full agent roster", inline=False)
    embed.add_field(name="/agent <name>", value="Details for one agent", inline=False)
    embed.add_field(name="/credits", value="Upstream attribution", inline=False)
    embed.set_footer(text="Mention the bot for a short help. Rootless lab only.")
    await interaction.response.send_message(embed=embed)

@bot.tree.command(name="status", description="GrokHunter version and links")
async def status(interaction: discord.Interaction):
    embed = discord.Embed(
        title="GrokHunter Rootless",
        description="Kali NetHunter (rootless) × Grok Build coding lab for unrooted Android.",
        color=0x00E5C7,
    )
    embed.add_field(name="Release", value="v1.0.10", inline=True)
    embed.add_field(name="Grok Build", value="≥ 1.0.5 · default grok-4.6", inline=True)
    embed.add_field(
        name="Links",
        value="[Repo](https://github.com/FineComputer14451/GrokHunter) · [Site](https://finecomputer14451.github.io/GrokHunter/)",
        inline=False,
    )
    embed.add_field(
        name="Install (Termux)",
        value="`bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh)`",
        inline=False,
    )
    embed.set_footer(text="Not affiliated with xAI, OffSec, Termux, or jorexdeveloper — we credit them.")
    await interaction.response.send_message(embed=embed)

@bot.tree.command(name="agents", description="List Coding Team + lab agents")
async def agents(interaction: discord.Interaction):
    lines = [f"**{name}** — {desc}" for name, desc in AGENTS.items()]
    text = "\n".join(lines)
    if len(text) > 1900:
        text = text[:1900] + "\n…"
    await interaction.response.send_message(f"**GrokHunter agents**\n{text}")

@bot.tree.command(name="agent", description="Get details for one agent")
@app_commands.describe(name="Agent name (e.g. benjamin, lucas, scout)")
async def agent(interaction: discord.Interaction, name: str):
    key = name.lower().strip()
    desc = AGENTS.get(key)
    if desc:
        await interaction.response.send_message(f"**{key}** — {desc}")
    else:
        await interaction.response.send_message(
            f"Unknown agent `{name}`. Try `/agents` for the full list.",
            ephemeral=True,
        )

@bot.tree.command(name="credits", description="Who we stand on")
async def credits(interaction: discord.Interaction):
    await interaction.response.send_message(
        "**Credits**\n"
        "• Install engine: jorexdeveloper (termux-nethunter / termux-distro)\n"
        "• Host: Termux team\n"
        "• Guest OS: Kali / Offensive Security NetHunter rootfs\n"
        "• AI: xAI Grok Build\n\n"
        "GrokHunter is an overlay. We are not affiliated. See CREDITS.md in the repo."
    )

@bot.tree.error
async def on_app_command_error(interaction: discord.Interaction, error: app_commands.AppCommandError):
    await interaction.response.send_message(
        f"Command failed: `{error}`", ephemeral=True
    )

@bot.event
async def on_message(message: discord.Message):
    if message.author == bot.user:
        return
    if bot.user in message.mentions or (
        message.reference
        and message.reference.resolved
        and message.reference.resolved.author == bot.user
    ):
        await message.channel.send(
            "Grok online — Coding Team Leader. Heavy loop ready.\n"
            "Use `/help`, `/status`, `/agents`, `/agent`, `/credits`, or `/ping`.\n"
            "Rootless lab only. No offensive activity."
        )
    await bot.process_commands(message)

if __name__ == "__main__":
    if not TOKEN:
        raise SystemExit("DISCORD_TOKEN missing. Copy .env.example → .env and fill it.")
    bot.run(TOKEN)
