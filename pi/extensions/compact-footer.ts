import type { AssistantMessage } from "@earendil-works/pi-ai";
import type {
  ContextUsage,
  ExtensionAPI,
  ExtensionContext,
  ReadonlyFooterDataProvider,
  SessionEntry,
  SessionStartEvent,
  Theme,
} from "@earendil-works/pi-coding-agent";
import {
  truncateToWidth,
  type TUI,
  visibleWidth,
} from "@earendil-works/pi-tui";

// Catppuccin Frappé, matching @catppuccin_flavor in dot-tmux.conf.
const FRAPPE = {
  blue: "#8caaee",
  green: "#a6d189",
  lavender: "#babbf1",
  mauve: "#ca9ee6",
  overlay: "#737994",
  peach: "#ef9f76",
  pink: "#f4b8e4",
  red: "#e78284",
  sapphire: "#85c1dc",
  sky: "#99d1db",
  teal: "#81c8be",
  yellow: "#e5c890",
} as const;

type FrappeColor = keyof typeof FRAPPE;

interface UsageTotals {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  latestCacheHitRate?: number;
}

function color(name: FrappeColor, text: string): string {
  const hex = FRAPPE[name].slice(1);
  const red = Number.parseInt(hex.slice(0, 2), 16);
  const green = Number.parseInt(hex.slice(2, 4), 16);
  const blue = Number.parseInt(hex.slice(4, 6), 16);
  return `\u001b[38;2;${red};${green};${blue}m${text}\u001b[39m`;
}

function formatCount(value: number): string {
  if (value < 1_000) return `${value}`;
  if (value < 10_000) return `${(value / 1_000).toFixed(1)}k`;
  if (value < 1_000_000) return `${Math.round(value / 1_000)}k`;
  return `${(value / 1_000_000).toFixed(1)}M`;
}

function formatCwd(cwd: string): string {
  const home = process.env.HOME;
  if (!home) return cwd;
  if (cwd === home) return "~";
  return cwd.startsWith(`${home}/`) ? `~/${cwd.slice(home.length + 1)}` : cwd;
}

function getContextColor(percent: number | null): FrappeColor {
  if (percent === null) return "overlay";
  if (percent > 90) return "red";
  if (percent > 70) return "yellow";
  return "green";
}

function collectUsage(entries: readonly SessionEntry[]): UsageTotals {
  const totals: UsageTotals = {
    input: 0,
    output: 0,
    cacheRead: 0,
    cacheWrite: 0,
    cost: 0,
  };

  for (const entry of entries) {
    if (entry.type !== "message" || entry.message.role !== "assistant")
      continue;

    const message = entry.message as AssistantMessage;
    totals.input += message.usage.input;
    totals.output += message.usage.output;
    totals.cacheRead += message.usage.cacheRead;
    totals.cacheWrite += message.usage.cacheWrite;
    totals.cost += message.usage.cost.total;

    const promptTokens =
      message.usage.input + message.usage.cacheRead + message.usage.cacheWrite;
    if (promptTokens > 0) {
      totals.latestCacheHitRate =
        (message.usage.cacheRead / promptTokens) * 100;
    }
  }

  return totals;
}

function buildUsageParts(
  totals: UsageTotals,
  context: ContextUsage | undefined,
): string[] {
  const parts: string[] = [];

  if (totals.input > 0)
    parts.push(color("sky", `↑${formatCount(totals.input)}`));
  if (totals.output > 0)
    parts.push(color("green", `↓${formatCount(totals.output)}`));
  if (totals.cacheRead > 0)
    parts.push(color("teal", `R${formatCount(totals.cacheRead)}`));
  if (totals.cacheWrite > 0)
    parts.push(color("sapphire", `W${formatCount(totals.cacheWrite)}`));
  if (totals.latestCacheHitRate !== undefined) {
    parts.push(color("pink", `CH${totals.latestCacheHitRate.toFixed(1)}%`));
  }
  if (totals.cost > 0)
    parts.push(color("yellow", `$${totals.cost.toFixed(3)}`));

  if (context) {
    const percent = context.percent === null ? "?" : context.percent.toFixed(1);
    parts.push(
      color(
        getContextColor(context.percent),
        `${percent}%/${formatCount(context.contextWindow)}`,
      ),
    );
  }

  return parts;
}

function renderFooter(
  width: number,
  ctx: ExtensionContext,
  theme: Theme,
  branch: string | null,
): string[] {
  const sessionName = ctx.sessionManager.getSessionName();
  const location =
    color("blue", formatCwd(ctx.cwd)) +
    (branch
      ? color("overlay", " (") + color("mauve", branch) + color("overlay", ")")
      : "") +
    (sessionName ? color("overlay", " • ") + color("pink", sessionName) : "");
  const usage = buildUsageParts(
    collectUsage(ctx.sessionManager.getEntries()),
    ctx.getContextUsage(),
  );
  const model = theme.bold(color("lavender", ctx.model?.id ?? "no-model"));
  const thinking = ctx.model?.reasoning
    ? color("peach", ` • ${ctx.thinkingLevel}`)
    : "";
  const separator = color("overlay", " ");
  const divider = color("overlay", " │ ");
  const right = `${usage.join(separator)}${usage.length > 0 ? divider : ""}${model}${thinking}`;
  const gap = 2;

  if (visibleWidth(location) + gap + visibleWidth(right) <= width) {
    const padding = " ".repeat(
      width - visibleWidth(location) - visibleWidth(right),
    );
    return [`${location}${padding}${right}`];
  }

  return [
    truncateToWidth(`${location}  ${right}`, width, color("overlay", "...")),
  ];
}

export default function compactFooter(pi: ExtensionAPI): void {
  pi.on("session_start", (_event: SessionStartEvent, ctx: ExtensionContext) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter(
      (tui: TUI, theme: Theme, footerData: ReadonlyFooterDataProvider) => {
        const unsubscribe = footerData.onBranchChange(() =>
          tui.requestRender(),
        );

        return {
          dispose: unsubscribe,
          invalidate() {},
          render: (width: number) =>
            renderFooter(width, ctx, theme, footerData.getGitBranch()),
        };
      },
    );
  });
}
