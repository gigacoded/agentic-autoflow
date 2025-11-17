# Common Component Patterns

## Layout Components

### Container

```typescript
interface ContainerProps {
  children: React.ReactNode;
  className?: string;
}

export function Container({ children, className = "" }: ContainerProps) {
  return (
    <div className={`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 ${className}`}>
      {children}
    </div>
  );
}
```

### Section

```typescript
interface SectionProps {
  children: React.ReactNode;
  className?: string;
}

export function Section({ children, className = "" }: SectionProps) {
  return (
    <section className={`py-12 md:py-16 lg:py-20 ${className}`}>
      {children}
    </section>
  );
}
```

## UI Components

### Card

```typescript
interface CardProps {
  children: React.ReactNode;
  hover?: boolean;
  className?: string;
}

export function Card({ children, hover = false, className = "" }: CardProps) {
  return (
    <div
      className={`
        bg-white rounded-lg shadow-md p-6
        ${hover ? "transition-shadow hover:shadow-lg" : ""}
        ${className}
      `}
    >
      {children}
    </div>
  );
}
```

### Input

```typescript
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, className = "", ...props }, ref) => {
    return (
      <div className="space-y-1">
        {label && (
          <label htmlFor={props.id} className="block text-sm font-medium text-gray-700">
            {label}
          </label>
        )}
        <input
          ref={ref}
          className={`
            w-full px-3 py-2 border rounded-md
            focus:outline-none focus:ring-2 focus:ring-blue-500
            ${error ? "border-red-500" : "border-gray-300"}
            ${className}
          `}
          {...props}
        />
        {error && <p className="text-sm text-red-600">{error}</p>}
      </div>
    );
  }
);

Input.displayName = "Input";
```

### Modal

```typescript
"use client";

import { useEffect } from "react";

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
}

export function Modal({ isOpen, onClose, title, children }: ModalProps) {
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };

    if (isOpen) {
      document.addEventListener("keydown", handleEscape);
      document.body.style.overflow = "hidden";
    }

    return () => {
      document.removeEventListener("keydown", handleEscape);
      document.body.style.overflow = "unset";
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black bg-opacity-50"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative bg-white rounded-lg shadow-xl max-w-md w-full mx-4 p-6">
        {title && (
          <h2 className="text-xl font-semibold mb-4">{title}</h2>
        )}
        {children}
      </div>
    </div>
  );
}
```

## Data Display Components

### Loading Spinner

```typescript
export function LoadingSpinner({ size = "md" }: { size?: "sm" | "md" | "lg" }) {
  const sizeClasses = {
    sm: "h-4 w-4",
    md: "h-8 w-8",
    lg: "h-12 w-12",
  };

  return (
    <div className="flex justify-center items-center">
      <div
        className={`${sizeClasses[size]} border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin`}
      />
    </div>
  );
}
```

### Empty State

```typescript
interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  description?: string;
  action?: React.ReactNode;
}

export function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-12 text-center">
      {icon && <div className="mb-4 text-gray-400">{icon}</div>}
      <h3 className="text-lg font-medium text-gray-900 mb-2">{title}</h3>
      {description && <p className="text-gray-600 mb-4 max-w-sm">{description}</p>}
      {action}
    </div>
  );
}
```

### Error Message

```typescript
interface ErrorMessageProps {
  message: string;
  retry?: () => void;
}

export function ErrorMessage({ message, retry }: ErrorMessageProps) {
  return (
    <div className="bg-red-50 border border-red-200 rounded-lg p-4">
      <p className="text-red-800">{message}</p>
      {retry && (
        <button
          onClick={retry}
          className="mt-2 text-sm text-red-600 hover:text-red-700 font-medium"
        >
          Try again
        </button>
      )}
    </div>
  );
}
```

## Data Fetching Patterns

### List with Loading and Error States

```typescript
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function PostsList() {
  const posts = useQuery(api.posts.list);

  // Loading state
  if (posts === undefined) {
    return <LoadingSpinner />;
  }

  // Error state (Convex returns undefined on error)
  if (posts === null) {
    return <ErrorMessage message="Failed to load posts" />;
  }

  // Empty state
  if (posts.length === 0) {
    return (
      <EmptyState
        title="No posts yet"
        description="Be the first to create a post!"
        action={<Button>Create Post</Button>}
      />
    );
  }

  // Success state
  return (
    <div className="space-y-4">
      {posts.map(post => (
        <PostCard key={post._id} post={post} />
      ))}
    </div>
  );
}
```

### Infinite Scroll / Pagination

```typescript
"use client";

import { usePaginatedQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function InfinitePostsList() {
  const { results, status, loadMore } = usePaginatedQuery(
    api.posts.list,
    {},
    { initialNumItems: 10 }
  );

  return (
    <div className="space-y-4">
      {results.map(post => (
        <PostCard key={post._id} post={post} />
      ))}

      {status === "CanLoadMore" && (
        <button
          onClick={() => loadMore(10)}
          className="w-full py-2 bg-gray-100 hover:bg-gray-200 rounded"
        >
          Load More
        </button>
      )}

      {status === "LoadingMore" && <LoadingSpinner />}
    </div>
  );
}
```

## Advanced Patterns

### Debounced Search

```typescript
"use client";

import { useState, useEffect } from "react";
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useDebounce } from "@/hooks/useDebounce";

export function SearchPosts() {
  const [searchTerm, setSearchTerm] = useState("");
  const debouncedSearch = useDebounce(searchTerm, 300);

  const results = useQuery(
    api.posts.search,
    debouncedSearch ? { query: debouncedSearch } : "skip"
  );

  return (
    <div>
      <input
        type="search"
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        placeholder="Search posts..."
        className="w-full px-4 py-2 border rounded-md"
      />

      {debouncedSearch && (
        <div className="mt-4">
          {results === undefined ? (
            <LoadingSpinner />
          ) : results.length === 0 ? (
            <p className="text-gray-600">No results found</p>
          ) : (
            <div className="space-y-2">
              {results.map(post => (
                <PostCard key={post._id} post={post} />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
```

### Optimistic Updates

```typescript
"use client";

import { useMutation, useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useState } from "react";

export function TodoList() {
  const todos = useQuery(api.todos.list);
  const toggleTodo = useMutation(api.todos.toggle);
  const [optimisticUpdates, setOptimisticUpdates] = useState<Set<string>>(new Set());

  const handleToggle = async (todoId: string) => {
    // Add to optimistic updates
    setOptimisticUpdates(prev => new Set(prev).add(todoId));

    try {
      await toggleTodo({ id: todoId });
    } finally {
      // Remove from optimistic updates
      setOptimisticUpdates(prev => {
        const next = new Set(prev);
        next.delete(todoId);
        return next;
      });
    }
  };

  if (!todos) return <LoadingSpinner />;

  return (
    <ul className="space-y-2">
      {todos.map(todo => (
        <li key={todo._id} className="flex items-center gap-2">
          <input
            type="checkbox"
            checked={
              optimisticUpdates.has(todo._id)
                ? !todo.completed
                : todo.completed
            }
            onChange={() => handleToggle(todo._id)}
            className="h-4 w-4"
          />
          <span className={todo.completed ? "line-through text-gray-500" : ""}>
            {todo.text}
          </span>
        </li>
      ))}
    </ul>
  );
}
```
