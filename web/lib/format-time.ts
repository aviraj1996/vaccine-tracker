// Timestamp Formatter Utility
// Converts timestamps to relative time format (e.g., "2 minutes ago")

export function formatRelativeTime(dateString: string): string {
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffSeconds = Math.floor(diffMs / 1000);
  const diffMinutes = Math.floor(diffSeconds / 60);
  const diffHours = Math.floor(diffMinutes / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffSeconds < 10) {
    return 'just now';
  } else if (diffSeconds < 60) {
    return `${diffSeconds} seconds ago`;
  } else if (diffMinutes === 1) {
    return '1 minute ago';
  } else if (diffMinutes < 60) {
    return `${diffMinutes} minutes ago`;
  } else if (diffHours === 1) {
    return '1 hour ago';
  } else if (diffHours < 24) {
    return `${diffHours} hours ago`;
  } else if (diffDays === 1) {
    return '1 day ago';
  } else if (diffDays < 7) {
    return `${diffDays} days ago`;
  } else {
    // For older than a week, show actual date
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
  }
}

export function formatAbsoluteTime(dateString: string): string {
  const date = new Date(dateString);
  return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}
