export default function ProjectCard({ title, subtitle, description, image }) {
    return (
      <div className="bg-white rounded-xl shadow-md overflow-hidden w-64">
        <img src={image} alt={title} className="h-40 w-full object-cover" />
        <div className="p-4">
          <h4 className="text-xs text-gray-500">{subtitle}</h4>
          <h2 className="text-lg font-semibold mb-2">{title}</h2>
          <p className="text-sm text-gray-600">{description}</p>
          <button className="mt-4 text-pink-600 border border-pink-600 rounded px-3 py-1 text-sm hover:bg-pink-50">
            View Project
          </button>
        </div>
      </div>
    );
  }
  