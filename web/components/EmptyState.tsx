// Empty State Component
// Shows when no data is available with optional call-to-action

interface EmptyStateProps {
  icon?: string;
  title: string;
  description: string;
  actionText?: string;
  actionHref?: string;
}

export default function EmptyState({
  icon = '📭',
  title,
  description,
  actionText,
  actionHref,
}: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center h-64 text-gray-400">
      <div className="text-6xl mb-4">{icon}</div>
      <h3 className="text-lg font-medium text-gray-700 mb-2">{title}</h3>
      <p className="text-sm text-gray-500 mb-4 text-center max-w-md">{description}</p>
      {actionText && actionHref && (
        <a
          href={actionHref}
          className="text-blue-600 hover:text-blue-800 font-medium text-sm"
        >
          {actionText} →
        </a>
      )}
    </div>
  );
}
